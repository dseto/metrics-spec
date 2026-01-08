# Prompts (Spec-driven)

Data: 2026-01-07

Este arquivo existe para orientar automações/agentes (ex.: GitHub Copilot) quando estiverem implementando ou revisando mudanças guiadas pelo spec deck.

## Orientação mínima para agentes

1. Leia primeiro:
   - `specs/backend/08-ai-assist/ai-provider-contract.md`
   - `specs/backend/08-ai-assist/ai-endpoints.md`
   - `specs/backend/04-execution/02-dependency-injection.md`
   - `specs/backend/04-execution/03-environment-configuration.md`
   - `specs/backend/09-testing/01-it04-ai-dsl-generate-tests.md`
2. Garanta que:
   - `dslProfile == "ir"` em todos os requests/responses relevantes
   - AI endpoints exijam auth (Bearer)
   - `AddHttpClient("AI")` esteja presente antes de registrar dependências que usam `IHttpClientFactory`
3. Não introduza `jsonata`/`Gemini` novamente (somente docs históricos).

