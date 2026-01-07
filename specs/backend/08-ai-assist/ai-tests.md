# AI Tests (Design-time)

Data: 2026-01-07

## Unit tests
Cobrir:
- Provider retorna payload válido e inválido
- Parser/validator rejeita:
  - JSON inválido (não parseia)
  - Plan inválido (schema `planV1.schema.json`)
  - outputSchema inválido
- Fallback por templates:
  - quando LLM falha → template T1/T2/T5 é selecionado
  - `planSource` é registrado corretamente (ex.: `template:T2`)

## Integration tests (API)
Fluxos mínimos:

### 1) Generate (plan_v1)
- `POST /api/v1/ai/dsl/generate`
  - 200 quando habilitado + provider ok
  - assert: `dsl.profile == "plan_v1"`
  - assert: `plan != null` (sempre populado)

### 2) Preview/Transform (plan_v1)
- `POST /api/v1/preview/transform`
  - request inclui `plan`
  - assert: `isValid == true` para casos determinísticos (templates)

### 3) Erros
- 503 `AI_DISABLED` quando desabilitado
- 503 `AI_OUTPUT_INVALID` quando provider retorna output ruim e não há template aplicável
- 400 quando `plan` inválido (schema / parse)
- 400 quando execução falha (ex.: groupBy em field inexistente)
- 200 com `isValid=false` quando rows violam `outputSchema`

## Golden vectors
- Reutilizar:
  - `specs/shared/examples/dslGenerateResult.plan_v1.sample.json`
  - `specs/shared/examples/previewRequest.plan_v1.sample.json`
- Manter samples legacy quando necessário:
  - `*.legacy.sample.json`
  - `previewRequest.jsonata.sample.json`

## Documentação de suporte
- Padrão de testes: `docs/TESTING_PLANV1.md`
