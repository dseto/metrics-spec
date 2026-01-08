# Release Notes — Spec Deck Delta (IR/OpenRouter)

Data: 2026-01-07

## Added

- Docs de setup do OpenRouter e troubleshooting.
- Doc completo de abstração do LLM provider (`IAiProvider`) e padrão de erros/retry.
- Docs de DI (incluindo `AddHttpClient("AI")`) e configuração por ambiente.
- Docs específicos dos testes de integração IT04 (AI Generate) e IT13 (PlanV1 flow).
- `docs/TECH_DEBT.md` para registrar histórico e pendências.

## Changed

- `dslProfile` → agora **somente `ir`** (JSONata removido).
- `DslGenerateRequest.engine` → agora **somente `plan_v1`**.
- Exemplos e schemas atualizados para refletir `ir` + `plan`.
- AI endpoints documentados como **auth-required** (Bearer JWT).

## Deprecated / Removed (behavior)

- Profile `jsonata` e engine `legacy` removidos do backend (requests devem receber 400/validation).
- Configuração `GeminiConfig` removida de `appsettings*`.

