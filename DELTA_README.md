# DELTA Spec Deck — Backend (IR-only + OpenRouter-only)

Data: 2026-01-07

Este delta pack atualiza o **spec deck** para refletir o estado real do backend após:

- remoção completa do engine legacy **JSONata** e migração total para **PlanV1 (profile `ir`)**;
- remoção do provider **Gemini** e padronização em **OpenRouter (OpenAI-compatible)**;
- correção e documentação do bug crítico de DI (`IHttpClientFactory` → `AddHttpClient("AI")`);
- documentação completa para eliminar **tribal knowledge** (auth LLM, env loading, testes, DI, provider abstraction).

## Como aplicar

1. Extraia este ZIP na raiz do repositório do spec deck (ou na raiz do projeto, conforme seu fluxo).
2. **Copie/mescle** a pasta `specs/` e `docs/`, sobrescrevendo os arquivos existentes.
3. Rode um check rápido:
   - links internos dos docs (paths)
   - validação JSON dos schemas (`specs/shared/domain/schemas/*.json`)
   - (opcional) `dotnet test` no backend para validar coerência.

## Principais mudanças

- `dslProfile` agora é **somente** `"ir"`.
- `engine` em `DslGenerateRequest` agora é **somente** `"plan_v1"`.
- Todos os AI endpoints exigem **Bearer token**.
- Testes de LLM real são isolados por `[Trait("Category","LLM")]` e usam `METRICS_OPENROUTER_API_KEY`.
- `.env` é carregado automaticamente nos testes via `TestWebApplicationFactory.LoadEnvFile()`.

## Arquivos adicionados (novos)

- `specs/backend/08-ai-assist/01-openrouter-setup.md`
- `specs/backend/08-ai-assist/02-llm-provider-abstraction.md`
- `specs/backend/08-ai-assist/ai-provider-contract.md`
- `specs/backend/04-execution/02-dependency-injection.md`
- `specs/backend/04-execution/03-environment-configuration.md`
- `specs/backend/09-testing/01-it04-ai-dsl-generate-tests.md`
- `specs/backend/09-testing/02-it13-llm-integration-tests.md`
- `docs/TECH_DEBT.md`

## Arquivos atualizados (overwrite)

- `specs/backend/08-ai-assist/ai-endpoints.md`
- `specs/backend/08-ai-assist/ai-tests.md`
- `specs/backend/05-transformation/dsl-engine.md`
- `specs/backend/05-transformation/plan-v1-spec.md`
- `specs/backend/07-plan-execution.md`
- `specs/backend/03-engine.md`
- `specs/backend/00-vision/spec-index.md`
- `specs/backend/09-testing/integration-tests.md`
- `docs/TESTING_PLANV1.md`
- `docs/MIGRATION_JSONATA_TO_PLANV1.md` (conteúdo atualizado para IR)
- `specs/RELEASE_NOTES.md`
- Schemas e exemplos em `specs/shared/...`

