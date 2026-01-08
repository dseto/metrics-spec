# OpenRouter Setup (LLM Real)

Data: 2026-01-07

Este documento descreve como habilitar o **LLM real via OpenRouter** em ambiente local/dev/test.

---

## O que é usado no projeto

- Provider atual: **OpenRouter**
- Tipo de endpoint: **OpenAI-compatible Chat Completions**
- Endpoint padrão: `https://openrouter.ai/api/v1/chat/completions`
- Modelo usado nos testes (exemplo): `deepseek/deepseek-chat-v3.1`

---

## 1) Obter API key

1. Criar conta no OpenRouter
2. Gerar API key (formato típico: `sk-or-v1-...`)
3. (Opcional) adicionar crédito/limite

> Segurança: não comitar keys no repo.

---

## 2) Configurar ambiente local

### Via variável de ambiente
```bash
export METRICS_OPENROUTER_API_KEY="sk-or-v1-..."
```

### Via `.env` (recomendado para dev/test)
Crie um arquivo `.env` na raiz do repositório:

```env
METRICS_OPENROUTER_API_KEY=sk-or-v1-...
```

Os testes carregam esse arquivo automaticamente (ver `specs/backend/08-ai-assist/ai-tests.md`).

---

## 3) Smoke test via API (com auth)

1) Obtenha um token (dev/test):
```bash
TOKEN=$(curl -s -X POST http://localhost:5000/api/auth/token \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"testpass123"}' | jq -r .access_token)
```

2) Chame `generate`:
```bash
curl -s -X POST http://localhost:5000/api/v1/ai/dsl/generate \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d @specs/shared/examples/dslGenerateRequest.sample.json
```

Resultado esperado:
- HTTP 200
- `dsl.profile == "ir"`
- `plan.steps` não vazio

---

## Troubleshooting

### 401/403
- Token ausente ou inválido → obtenha novo token e envie `Authorization: Bearer ...`

### 429 / rate limit
- Reduzir paralelismo de testes LLM
- Aumentar retries/backoff (ver doc de provider)
- Verificar saldo/limite da API key

### 5xx do provider
- Repetir com retry
- Validar endpoint e chave

