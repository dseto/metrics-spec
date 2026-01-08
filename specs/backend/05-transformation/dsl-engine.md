# DSL / Transform Engine Spec

Data: 2026-01-07

Perfis suportados (backend):
- `ir` (**recomendado / default**) — PlanV1 IR determinístico (execução via PlanExecutor)
- `custom` (reservado; futuro)

Perfis removidos:
- `jsonata` (legacy) — removido do backend em 2026-01-07

---

## Pipeline canônico (Engine)

### A) Execução determinística a partir de `plan` (IR)

1) **PlanExecutor**: executar `plan` (recordPath + steps) sobre o JSON de input
2) **EngineService**:
   - validar `rowsArray` contra `outputSchema`
   - gerar CSV determinístico

Para este modo, a Engine expõe o helper:
- `TransformValidateToCsvFromRows(rowsArray, outputSchema)`

Documentação completa:
- `specs/backend/07-plan-execution.md`
- `specs/backend/03-engine.md`
- `specs/backend/05-transformation/plan-v1-spec.md`

---

## outputSchema (validação)

- `outputSchema` é JSON Schema draft 2020-12
- MUST ser **self-contained**:
  - permitido: `$ref` interno (ex.: `#/definitions/...`)
  - proibido: `$ref` externo por arquivo/URL (sem contexto de path em runtime)

---

## Compatibilidade

Versões antigas com `dsl.profile="jsonata"` devem ser migradas/regeradas para `ir`.
Ver: `docs/MIGRATION_JSONATA_TO_PLANV1.md`

