# Engine Service (Transform & Validation)

Data: 2026-01-07

## Contexto

O backend possui um engine responsável por:
- executar transformações determinísticas a partir de `plan` (IR),
- validar saída contra JSON Schema,
- gerar CSV com base nas rows finais.

Historicamente, o engine executava transformações a partir de DSL (ex.: `jsonata`).
Após a migração, a execução principal ocorre via `PlanExecutor` e o engine opera no modo “rows-based”.

---

## Modo suportado: Rows-based (IR)

1) `PlanExecutor` executa `plan` e gera `rowsArray`
2) `EngineService` valida e gera CSV:
   - `TransformValidateToCsvFromRows(rowsArray, outputSchema)`

---

## Erros e contratos

- Se `rowsArray` não for array → erro de request (400)
- Se `rowsArray` for array mas violar `outputSchema` → retorno `200 OK` com `isValid=false` no preview

---

## Testes obrigatórios

- IT13 cobre execução determinística end-to-end
- IT04 cobre geração de plano (AI endpoint) e validações

Docs:
- `specs/backend/09-testing/01-it04-ai-dsl-generate-tests.md`
- `specs/backend/09-testing/02-it13-llm-integration-tests.md`

