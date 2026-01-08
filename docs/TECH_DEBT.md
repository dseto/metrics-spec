# TECH_DEBT (Backend)

Data: 2026-01-07

Este documento registra pendências e decisões históricas para evitar “tribal knowledge”.

---

## 1) Histórico relevante (resumo)

- O backend migrou para execução determinística com PlanV1.
- O provider Gemini foi removido (nunca foi usado).
- JSONata foi removido do backend e o único profile suportado passou a ser `ir`.
- Houve um bug crítico de DI (`IHttpClientFactory`) corrigido com `AddHttpClient("AI")`.

---

## 2) Pendências (priorizadas)

### P1 — MockProvider para testes determinísticos de AI
Objetivo: permitir testes de `generate` sem depender de OpenRouter.

- Implementar `MockProvider` (ver `specs/backend/08-ai-assist/02-llm-provider-abstraction.md`)
- Adicionar testes cobrindo:
  - output inválido
  - timeout
  - rate-limit

### P1 — Observabilidade completa de `planSource`
Garantir logs/métricas consistentes para:
- explicit
- llm
- template:T1|T2|T5

### P2 — Arquivamento de docs legacy
- Manter referência histórica de JSONata apenas em docs de migração
- Se existirem docs antigos de Gemini, mover para `docs/archived/`

---

## 3) O que NÃO fazer (para evitar regressões)

- Reintroduzir `jsonata` no backend
- Reintroduzir `GeminiConfig` em appsettings
- Remover requirement de auth para endpoints de AI (auditabilidade é requisito)

