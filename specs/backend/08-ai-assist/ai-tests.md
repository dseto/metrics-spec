# AI Tests (Design-time)

Data: 2026-01-07

Este documento padroniza como testar a geração de DSL/Plan (design-time),
incluindo testes determinísticos e testes com **LLM real (OpenRouter)**.

---

## Objetivos

- Garantir que `POST /api/v1/ai/dsl/generate`:
  - valida input corretamente,
  - retorna `dslProfile="ir"` + `plan` válido,
  - aplica fallback por templates quando necessário,
  - se integra ao fluxo de auth/audit.

---

## Test suites relevantes

### IT04 — AI DSL Generate (Integration)
Documento detalhado: `specs/backend/09-testing/01-it04-ai-dsl-generate-tests.md`

Cobertura (esperada):
- 2 testes LLM real (categoria **LLM**) retornando plano válido
- 2 testes de validação (categoria **Validation**) retornando 400

### IT13 — PlanV1/IR end-to-end flow (Integration)
Documento detalhado: `specs/backend/09-testing/02-it13-llm-integration-tests.md`

Cobertura (esperada):
- testes determinísticos do PlanExecutor (sem LLM)
- cobre: recordPath discovery, select/filter/groupBy/mapValue/limit

---

## Variáveis de ambiente

### Obrigatória para testes LLM real
- `METRICS_OPENROUTER_API_KEY`  
  Exemplo: `sk-or-v1-*`

Sem esta variável:
- recomenda-se rodar a suite offline (sem filtro `Category=LLM`)
- ou rodar com filtro explícito para excluir `LLM`

### Auth de testes (dev/test)
- `Auth:LocalJwt:EnableBootstrapAdmin=true` (ou equivalente via env)
- credenciais bootstrap típicas (dev/test): `admin / testpass123`

> Em produção, bootstrap admin deve estar desabilitado e secrets devem vir de secret store.

---

## .env file loading (tests)

Os testes carregam `.env` automaticamente via `TestWebApplicationFactory.LoadEnvFile()`.

Ordem de busca (do contexto de `bin/Debug/netX.Y`):
1. `../../../../../.env`
2. `./.env`
3. `../../../.env`
4. fallback absoluto (somente em alguns ambientes de dev)

Recomendação: mantenha `.env` **na raiz do repo**.

---

## Como rodar

### Tudo (inclui LLM se chave existir)
```bash
dotnet test Metrics.Simple.SpecDriven.sln
```

### Apenas testes LLM (requer `METRICS_OPENROUTER_API_KEY`)
```bash
dotnet test Metrics.Simple.SpecDriven.sln --filter "Category=LLM"
```

### Apenas validação (sem LLM)
```bash
dotnet test Metrics.Simple.SpecDriven.sln --filter "Category=Validation"
```

### Apenas PlanV1/IR (sem LLM)
```bash
dotnet test Metrics.Simple.SpecDriven.sln --filter "Category=PlanV1"
```

---

## Boas práticas para testes LLM

- Sempre marcar testes LLM com: `[Trait("Category","LLM")]`
- Não depender de resposta exata do LLM; validar invariantes:
  - status 200
  - `dsl.profile == "ir"`
  - `plan.steps` não vazio
  - `plan` valida contra schema
- Logar (e/ou assertar) que o plano veio de LLM vs template quando relevante.

