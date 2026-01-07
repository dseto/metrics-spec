# MIGRATION_JSONATA_TO_PLANV1

Data: 2026-01-07

## Objetivo

Guiar a migração do ecossistema (backend + clients) do perfil legacy `jsonata`
para o perfil recomendado `plan_v1`.

---

## Breaking changes (principais)

1) Preview/Transform agora pode exigir `plan`
- Quando `dsl.profile == "plan_v1"`, o request do preview deve enviar `plan`.

2) Resultado de generate agora inclui `plan`
- Para `plan_v1`, `dslGenerateResult.plan` deve estar preenchido.

3) OpenAPI / rotas versionadas
- Endpoints esperados:
  - `POST /api/v1/ai/dsl/generate`
  - `POST /api/v1/preview/transform`

---

## Estratégia recomendada

### Fase 0 — Preparação
- Atualizar contratos (schemas + openapi)
- Documentar Plan IR e fluxo de execução (spec deck)

### Fase 1 — Dual support
- Backend mantém `legacy` (quando necessário) e `plan_v1`
- Client passa a suportar `plan_v1` primeiro

### Fase 2 — Default plan_v1
- Config `AI:DefaultEngine = "plan_v1"`
- Suites de teste focam em `plan_v1`
- Legacy tests podem ser mantidos como `Skip`

### Fase 3 — Deprecar legacy
- Remover dependências de `jsonata` (quando não houver consumidores)
- Limpar fixtures e documentação legacy (opcional)

---

## Checklist para client (frontend/CLI)

- [ ] Enviar `engine:"plan_v1"` (ou `dslProfile:"plan_v1"`, dependendo do contrato)
- [ ] Capturar `plan` no response de generate
- [ ] Enviar `plan` no request de preview/transform
- [ ] Tratar erros 400 (plan inválido / execução falha) e 200 inválido (schema output)

---

## Referências
- `specs/backend/07-plan-execution.md`
- `specs/backend/05-transformation/plan-v1-spec.md`
- `specs/shared/openapi/config-api.yaml`
