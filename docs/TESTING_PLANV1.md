# TESTING_PLANV1 (IR)

Data: 2026-01-07

## Objetivo

Documentar o padrão de testes de integração (E2E) para fluxos **PlanV1/IR** (`dslProfile="ir"`),
evitando dependência de conhecimento tácito (“tribal knowledge”).

---

## Padrão de teste (integration)

### 1) Gerar DSL/Plan (design-time)
- Chamar `POST /api/v1/ai/dsl/generate` com:
  - `dslProfile="ir"`
  - `engine="plan_v1"` (se informado)
- Validar:
  - `dsl.profile == "ir"`
  - `plan != null` e `plan.steps` não vazio

> Nota: o endpoint é auth-required. Em dev/test, usar `/api/auth/token`.

### 2) Executar preview determinístico
- Chamar `POST /api/v1/preview/transform` enviando:
  - `sampleInput`
  - `outputSchema`
  - `plan`
- Validar:
  - `isValid == true`
  - `csvPreview` não vazio (quando aplicável)
  - `rowsArray` compatível com schema

---

## Classes de testes

- **PlanV1/IR determinístico**: sempre roda (sem dependências externas)
  - ver: `specs/backend/09-testing/02-it13-llm-integration-tests.md`
- **LLM real**: roda somente quando há key/config
  - ver: `specs/backend/09-testing/01-it04-ai-dsl-generate-tests.md`

---

## Notas sobre LLM real

Em ambientes com LLM real, é esperado que:
- algumas respostas não sejam JSON válido,
- alguns planos sejam inválidos,
- fallback por templates seja acionado.

Logo, recomenda-se:
- manter testes determinísticos por template (estáveis),
- isolar testes “real LLM” e permitir `Skip`/filtro quando necessário.

