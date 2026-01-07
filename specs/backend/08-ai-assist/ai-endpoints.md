# AI Endpoints (Design-time)

Data: 2026-01-07

> Este documento descreve o comportamento **implementado** após a migração do backend para o perfil **`plan_v1`**
> (Plan IR determinístico + execução server-side em Preview/Transform).

## Endpoints (versionados)

### 1) Gerar DSL/Plan
`POST /api/v1/ai/dsl/generate`

#### Schemas
- Request: `specs/shared/domain/schemas/dslGenerateRequest.schema.json`
- Response: `specs/shared/domain/schemas/dslGenerateResult.schema.json`
- Error (503): `specs/shared/domain/schemas/aiError.schema.json`

#### Comportamento (implementado)
1. Verificar se AI está habilitada (`AI.Enabled` em `appsettings.json`).
2. Validar request (tamanho e estrutura).
3. Selecionar engine:
   - Se request informar `engine`, usar o valor.
   - Caso contrário, usar `AI:DefaultEngine` (ver seção **Configuração**).
4. Gerar saída:
   - Para `plan_v1`: gerar **Plan IR** (JSON) + `DslDto { profile: "plan_v1" }`.
   - Para `legacy`: gerar DSL `jsonata` (quando suportado) + `DslDto { profile: "jsonata" }`.
5. Validar:
   - Se `plan_v1`: validar o Plan IR contra `specs/shared/domain/schemas/planV1.schema.json`
     (e regras adicionais do modelo `Plan` no código).
   - Se inválido / não parseável: acionar fallback por templates (T1/T2/T5).
6. (Opcional/recomendado) Executar preview interno para sanity-check:
   - input: `sampleInput`
   - dsl/profile/plan: gerados
   - schema: `outputSchema` gerado
7. Retornar:
   - `dslGenerateResult.plan` **deve** estar preenchido quando o engine/profile for `plan_v1`.

#### Observabilidade
Logar (Serilog) com:
- `correlationId` (header `X-Correlation-Id` quando presente)
- provider/model/promptVersion
- tamanho de input/output, latência, status (success/fail)
- `planSource`: `"llm" | "template:T1" | "template:T2" | "template:T5" | "explicit"`

> Importante: nunca logar segredos. `sampleInput` pode conter dados sensíveis: logar apenas tamanho/hash.

---

### 2) Preview Transform
`POST /api/v1/preview/transform`

#### Schemas
- Request: `specs/shared/domain/schemas/previewRequest.schema.json`
- Response: `specs/shared/domain/schemas/previewResult.schema.json`

#### Comportamento (resumo)
- Para `dsl.profile == "plan_v1"` e `plan != null`:
  - Executar o Plan server-side (PlanExecutor) e gerar `rows`
  - Validar `rows` contra `outputSchema` e gerar CSV (EngineService)
- Para outros perfis:
  - Executar caminho legacy (ex.: jsonata) — quando disponível

Para detalhes completos, ver: `specs/backend/07-plan-execution.md`.

---

## Configuração

### appsettings.json
```yaml
AI:
  Enabled: true|false
  DefaultEngine: "plan_v1" | "legacy"
```

- `DefaultEngine` é usado quando o client não especifica `engine`.
- Migração de `legacy` → `plan_v1` requer que o client suporte `plan` no preview (ver `previewRequest.schema.json`).

---

## Fallback por Templates (essencial em produção)

Quando o LLM falha (JSON inválido, plano inválido, etc.), o backend deve produzir um plano determinístico via templates:

- **T1**: Select all fields
- **T2**: Select specific fields (+ filtro opcional)
- **T5**: GroupBy + Aggregate

Detalhes e heurísticas: `specs/backend/07-plan-execution.md` e `specs/backend/05-transformation/plan-v1-spec.md`.
