# IT04 — AI DSL Generate Tests (Integration)

Data: 2026-01-07

Esta suite valida o endpoint de geração assistida por LLM:

- `POST /api/v1/ai/dsl/generate`

Objetivo: garantir invariantes do contrato (`dslProfile="ir"`, `plan` válido) e validar erros 400.

---

## Pré-requisitos

- Auth habilitada (LocalJwt em dev/test)
- Para testes LLM real:
  - `METRICS_OPENROUTER_API_KEY` configurada

---

## Fluxo de autenticação usado nos testes

1) Login:
- `POST /api/auth/token` com credenciais de teste (ex.: `admin/testpass123`)
2) Extrair `access_token`
3) Reutilizar token em requests AI:
- header `Authorization: Bearer <token>`

---

## Test cases (esperados)

### Category: LLM
- **GenerateDsl_SimpleExtraction_ReturnsValidPlan**
- **GenerateDsl_ComplexAggregation_ReturnsValidPlan**

Asserções mínimas:
- HTTP 200
- `dsl.profile == "ir"`
- `plan.steps.Count > 0`

### Category: Validation
- **GenerateDsl_InvalidConstraints_ReturnsBadRequest**
- **GenerateDsl_GoalTextTooShort_ReturnsBadRequest**

Asserções mínimas:
- HTTP 400
- body com mensagem/código de validação

---

## Como rodar

```bash
# apenas IT04
dotnet test Metrics.Simple.SpecDriven.sln --filter "FullyQualifiedName~IT04_AiDslGenerateTests"

# apenas LLM
dotnet test Metrics.Simple.SpecDriven.sln --filter "Category=LLM"
```

---

## Observabilidade esperada (logs)

- requestId/correlationId
- model/provider quando LLM real
- latência do provider
- origem do plano (`planSource`: llm vs template)

