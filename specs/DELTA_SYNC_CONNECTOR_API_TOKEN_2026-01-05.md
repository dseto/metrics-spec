# Delta Spec Deck — Full Sync (Backend + Frontend + Shared)
Data: 2026-01-05

Este delta é **incremental** sobre o spec deck base (specs.zip) e tem como objetivo
**equalizar o spec** com o que foi implementado no backend, frontend e shared
durante a implementação de:

- Connector: API Token criptografado + `hasApiToken`
- Runner: decriptação + injeção de Authorization
- SQLite: tabela `connector_tokens` + migration
- Auth admin: lookup case-insensitive + endpoint by-username
- Testes: formalização de IT04 (Version Lifecycle) e IT05 (Real LLM)
- Frontend: UX do API Token + runtime configuration (deployment-time config)

---

## Principais mudanças (contrato)

### Connector API Token
- `apiToken` (write-only) + `hasApiToken` (read-only)
- `apiTokenSpecified` (write-only) para distinguir omitido vs null no PUT

### Configuração
- `METRICS_SECRET_KEY` (base64, 32 bytes) obrigatória para encriptação/decriptação
- Tokens nunca retornam em GET e nunca podem aparecer em logs

### Runner
- Se token presente: `Authorization: Bearer <token>`
- Falha de decrypt => exit code 40 (SOURCE_ERROR)

### Frontend
- Campo password, indicador "Token configurado", clear/remove suportado
- Base URL carregada via RuntimeConfigService (`assets/config.json`)

---

## Arquivos incluídos neste delta

### Shared
- `shared/domain/schemas/connector.schema.json`
- `shared/openapi/config-api.yaml`

### Backend
- `backend/03-interfaces/api-behavior.md`
- `backend/03-interfaces/auth-api.md`
- `backend/04-execution/runner-pipeline.md`
- `backend/04-execution/cli-contract.md`
- `backend/06-storage/sqlite-schema.md`
- `backend/06-storage/migrations/002_connector_tokens.sql`
- `backend/09-testing/integration-tests.md`
- `backend/09-testing/security-auth-tests.md`

### Frontend
- `frontend/11-ui/pages/connectors.md`
- `frontend/11-ui/ui-field-catalog.md`
- `frontend/11-ui/ui-api-client-contract.md`
- `frontend/04-execution/runtime-configuration.md`
- `frontend/09-testing/gherkin/03-connectors.feature`

---

## Critérios de aceite (DoD)
- Connector GET nunca retorna token (somente `hasApiToken`)
- PUT suporta semântica omitido/manter, null/remover, string/substituir (via `apiTokenSpecified`)
- Runner injeta Authorization quando token presente e não vaza token em logs
- Migration cria `connector_tokens` e schema documentado
- IT04 roda sempre; IT05 condicional a API key
- UI não exibe token após salvar e mantém indicador coerente
