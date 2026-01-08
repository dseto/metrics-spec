# Integration Tests (E2E Backend)

Data: 2026-01-07

Este documento torna obrigatório que o backend possua **integration tests** cobrindo:
- pipelines reais (Runner/CLI) quando aplicável
- e o fluxo **AI-assisted** (design-time) + execução determinística (preview/transform)

---

## Regras

- Sem integration tests cobrindo o fluxo end-to-end principal, a entrega é considerada incompleta.
- Testes com LLM real devem ser:
  - isolados por `[Trait("Category","LLM")]`
  - rodáveis apenas quando `METRICS_OPENROUTER_API_KEY` estiver disponível

---

## AI-assisted DSL flow (IR)

Fluxo esperado (design-time + execução determinística):

1) `POST /api/v1/ai/dsl/generate` (auth-required)
   - request: `dslProfile="ir"`
   - response: `plan != null`
2) `POST /api/v1/preview/transform` enviando `plan`
3) Assert `isValid == true` e CSV gerado

Docs de referência:
- `docs/TESTING_PLANV1.md`
- `specs/backend/09-testing/01-it04-ai-dsl-generate-tests.md`
- `specs/backend/09-testing/02-it13-llm-integration-tests.md`

