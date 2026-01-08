# AI Endpoints (Design-time)

Data: 2026-01-07

Este documento descreve o comportamento **implementado** após a migração do backend para:
- engine **`plan_v1`**
- profile **`ir`** (PlanV1 IR / Intermediate Representation)

> **Importante:** todos os endpoints de AI são **auth-required** (Bearer JWT).

---

## 1) Gerar DSL/Plan (Design-time)

`POST /api/v1/ai/dsl/generate`

### Schemas
- Request: `specs/shared/domain/schemas/dslGenerateRequest.schema.json`
- Response: `specs/shared/domain/schemas/dslGenerateResult.schema.json`
- Plan: `specs/shared/domain/schemas/planV1.schema.json`

### Authentication requirements

Todos os endpoints de AI exigem **Authorization: Bearer <jwt>**.

Fluxo esperado (dev/test):
1. Login → `POST /api/auth/token` com credenciais (ex.: bootstrap admin)
2. Extrair `access_token`
3. Usar o token em todas as chamadas subsequentes

Exemplo HTTP:

```http
POST /api/v1/ai/dsl/generate HTTP/1.1
Authorization: Bearer eyJhbGciOi...
Content-Type: application/json

{
  "goalText": "Extrair timestamp e host e cpu em % do primeiro item",
  "sampleInput": { "result": [{ "timestamp": "2026-01-01T00:00:00Z", "host": "srv01", "cpu": 0.73 }] },
  "dslProfile": "ir",
  "engine": "plan_v1",
  "constraints": { "maxFields": 10 }
}
```

Exemplo cURL (dev):

```bash
# 1) obter token
TOKEN=$(curl -s -X POST http://localhost:5000/api/auth/token \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"testpass123"}' | jq -r .access_token)

# 2) chamar AI endpoint
curl -s -X POST http://localhost:5000/api/v1/ai/dsl/generate \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d @specs/shared/examples/dslGenerateRequest.sample.json
```

### Request invariants

- `dslProfile` MUST ser `"ir"`.
- `engine` (se informado) MUST ser `"plan_v1"`.
- `goalText` MUST ter tamanho mínimo (validação).
- `sampleInput` MUST ser JSON válido e **não vazio**.

### Response invariants

- `plan` MUST existir e ser válido conforme `planV1.schema.json`.
- `dsl.profile` MUST ser `"ir"`.
- `dsl.text` SHOULD conter uma representação string do plano (JSON-string).
- `outputSchema` SHOULD ser **self-contained** (sem `$ref` externo).

---

## Fallback por Templates (essencial em produção)

Quando o LLM falha (timeout, rate limit, JSON inválido, plano inválido, etc.),
o backend deve produzir um plano determinístico via templates:

- **T1**: Select all fields
- **T2**: Select specific fields (+ filtro opcional)
- **T5**: GroupBy + Aggregate

O resultado ainda deve respeitar:
- `dslProfile == "ir"`
- `plan` válido
- logs/telemetria indicando a origem do plano (`planSource = template:T*`)

Detalhes e heurísticas:
- `specs/backend/07-plan-execution.md`
- `specs/backend/05-transformation/plan-v1-spec.md`

---

## Unauthenticated vs Authenticated

- **Design-time (Studio / geração)**: requer auth (contexto do usuário, auditabilidade, custo LLM)
- **Runtime Transform (determinístico)**: não faz chamadas LLM; apenas executa `plan` existente

