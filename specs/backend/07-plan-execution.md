# Plan V1 Execution in Preview/Transform (Server-side)

Data: 2026-01-07

## Objetivo

Padronizar e documentar o fluxo **implementado** para executar transformações determinísticas
quando o DSL profile é **`plan_v1`**.

Este fluxo foi introduzido para:
- eliminar dependência de `jsonata` no caminho principal,
- permitir execução determinística (PlanExecutor),
- suportar fallback por templates quando LLM falha,
- reduzir “tribal knowledge” (contratos + erros + observabilidade).

---

## Quando este fluxo é acionado?

Endpoint:
- `POST /api/v1/preview/transform`

Condição:
- `request.dsl.profile == "plan_v1"` **e**
- `request.plan != null`

Contrato: `specs/shared/domain/schemas/previewRequest.schema.json`

> Nota: para perfis diferentes de `plan_v1` (ex.: `jsonata`), o backend pode manter um caminho legacy.

---

## Fluxo de execução (alto nível)

1. **Parse & validate request**
   - Validar `sampleInput` e `outputSchema` (JSON Schema).
   - Se `plan_v1`: validar `plan` contra `planV1.schema.json`.

2. **Execução do Plan (PlanExecutor)**
   - Determinar a coleção de registros:
     - Se `plan.recordPath` estiver definido: navegar até o array alvo.
     - Se `plan.recordPath` estiver ausente/nulo: o gerador **pode** aplicar RecordPathDiscovery antes
       de enviar o Plan (ver `plan-v1-spec.md`).
   - Executar cada `step` na ordem:
     - `select`, `filter`, `groupBy`, `mapValue`, `limit`, etc.

3. **Validação + CSV**
   - O PlanExecutor retorna `rows` (array de objetos JSON).
   - O Engine valida `rows` contra `outputSchema` e gera CSV.
   - Saída: `PreviewTransformResponseDto` (ver `previewResult.schema.json`).

---

## Integrações (código)

### Handlers
- `src/Api/Program.cs`: handler do endpoint Preview/Transform com branch `plan_v1`.

### Engine / Helpers
- `src/Engine/Engine.cs`: `TransformValidateToCsvFromRows(rowsArray, outputSchema)`.

### Plan runtime
- `src/Api/AI/Engines/PlanV1/PlanExecutor.cs`: execução determinística.
- `src/Api/AI/Engines/PlanV1/RecordPathDiscovery.cs`: heurística de descoberta de path.
- `src/Api/AI/Engines/PlanV1/PlanTemplates.cs`: templates T1/T2/T5.

---

## Contratos

### Request (previewRequest.schema.json)
Campos:
- `sampleInput` (required)
- `dsl` (required): `{ profile, text }`
- `outputSchema` (required)
- `plan` (optional): **obrigatório por regra quando `dsl.profile == "plan_v1"`**

### Response (previewResult.schema.json)
- `isValid`: boolean
- `errors`: lista (quando inválido)
- `csv`: string (quando válido)
- `rows`: array (opcional, dependendo da implementação)

---

## Tratamento de Erros

### 1) Plano inválido (schema / parse)
- **Quando**: `plan` não é JSON válido ou não passa validação de schema
- **Resposta**: `400 Bad Request`
- **Payload**: ApiError com detalhes de validação do schema

### 2) Falha de execução do plano
- **Quando**: op inválida, field inexistente em groupBy, etc.
- **Resposta**: `400 Bad Request`
- **Payload**: ApiError com mensagem `"Plan execution failed: ..."`

### 3) Falha de validação de output (rows vs outputSchema)
- **Quando**: rows não aderem ao schema
- **Resposta**: `200 OK` (pois é erro de validação de dados, não erro de infraestrutura)
- **Payload**: `PreviewTransformResult { isValid=false, errors=[...] }`

---

## Observabilidade

Recomendado logar:
- `correlationId` (header `X-Correlation-Id`)
- `dslProfile` e `engine` (quando aplicável)
- `planSource`:
  - `"explicit"` (plan enviado pelo client)
  - `"llm"` (gerado por LLM)
  - `"template:T1|T2|T5"` (fallback)
- Métricas:
  - contador por `planSource`
  - latência total do preview
  - latência de execução do Plan
  - quantidade de rows produzidas

---

## Fallback (onde acontece)

O **fallback para templates** acontece na **geração do Plan** (AI Engine), e não no Preview:
- se o LLM falhar ou gerar plano inválido, selecionar template (T1/T2/T5) e retornar Plan determinístico.

Detalhes: `specs/backend/05-transformation/plan-v1-spec.md` e `specs/backend/08-ai-assist/ai-endpoints.md`.
