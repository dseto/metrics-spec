# DSL / Transform Engine Spec

Data: 2026-01-07

Perfis suportados (backend):
- `plan_v1` (**recomendado / default**) — Plan IR determinístico (execução via PlanExecutor)
- `jsonata` (**legacy**) — mantido apenas para compatibilidade / migração
- `jmespath` (opcional; futuro)
- `custom` (reservado; pode retornar "not supported")

## Pipeline canônico (Engine)

### A) Legacy: execução a partir de DSL (ex.: jsonata)
A Engine deve seguir esta ordem:

1) **Transform**: executar DSL (`dsl.profile` + `dsl.text`) sobre o JSON de input
2) **Normalize Rows**: normalizar o output para "rows array" (array-of-objects)
3) **Validate Schema**: validar o output normalizado contra `outputSchema`
4) **Generate CSV**: gerar CSV determinístico conforme `csv-format.md` (inclui ordem de colunas)

Erros típicos:
- parse/compile -> `DSL_INVALID`
- runtime/eval -> `TRANSFORM_FAILED`

Determinismo:
- mesma entrada + mesma expressão -> mesmo output
- cache de expressão compilada é recomendado (por performance)

### B) Plan V1: execução a partir de Plan IR (rows-based)
Quando `dsl.profile == "plan_v1"` e `plan != null`, a execução acontece em duas fases:

1) **Execute Plan** (PlanExecutor)
   - entrada: `sampleInput` + `plan`
   - saída: `rowsArray` (array-of-objects)

2) **Validate + CSV** (Engine)
   - validar `rowsArray` contra `outputSchema`
   - gerar CSV determinístico

Para este modo, a Engine expõe o helper:
- `TransformValidateToCsvFromRows(rowsArray, outputSchema)`

Documentação completa: `specs/backend/07-plan-execution.md` e `specs/backend/03-engine.md`.

---

## outputSchema (validação)
- `outputSchema` é JSON Schema draft 2020-12
- MUST ser **self-contained**:
  - permitido: `$ref` interno (ex.: `#/definitions/...`)
  - proibido: `$ref` externo por arquivo/URL (sem contexto de path em runtime)
