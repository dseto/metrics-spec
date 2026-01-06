# DELTA — Confiabilidade da Geração de DSL (Jsonata)

## Novos documentos (Spec)

- `specs/backend/05-transformation/dsl-generation-reliability.md`
- `specs/backend/05-transformation/openrouter-structured-outputs-and-response-healing.md`
- `specs/backend/05-transformation/output-schema-inference.md`
- `specs/backend/05-transformation/retry-and-fallbacks.md`
- `specs/backend/05-transformation/field-renaming-policy.md`

## Novos documentos (Prompts)

- `prompts/backend/github-copilot-implement-dsl-reliability.md`
- `prompts/backend/github-copilot-refactor-prompt-system.md`
- `prompts/backend/github-copilot-update-it13-tests.md`

## Documentação de Templates

- `templates/dsl-template-library.md`

## Mudanças esperadas no código (orientação)

Arquivos existentes que deverão ser alterados (nomes conforme relatório):
- `src/Api/AI/HttpOpenAiCompatibleProvider.cs`  
  - request OpenRouter: `provider.require_parameters`, `provider.allow_fallbacks=false`
  - `response_format` com `json_schema.strict=true`
  - `plugins: [{ id: "response-healing" }]`
  - reduzir schema retornado pela LLM para `{ dsl: { text } }`
- `src/Api/Program.cs` (ou o endpoint equivalente)
  - fluxo: template → LLM → parse → validate/eval → repair → fallback
- `tests/Integration.Tests/IT13_LLMAssistedDslFlowTests.cs`
  - alinhar expectativa de renomeação de campos (policy)
