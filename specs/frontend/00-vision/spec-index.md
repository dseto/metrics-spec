# Frontend Spec Index

Data: 2026-01-08

## Shared contracts (read-only)
- OpenAPI: `../shared/openapi/config-api.yaml`
- Schemas: `../shared/domain/schemas/*.schema.json`
  - `dslGenerateRequest.schema.json`
  - `dslGenerateResult.schema.json`
  - `previewRequest.schema.json`
  - `planV1.schema.json`

## Segurança (mínima, curto prazo) — LocalJwt
- Domain: `02-domain/auth-domain.md`
- Auth API: `03-interfaces/auth-api.md`
- Flow & interceptors: `04-execution/auth-flow-and-interceptors.md`
- Login & access control (UX): `05-ui/login-and-access-control.md`
- Token storage: `06-storage/token-storage.md`

## UI
- UI specs: `11-ui/`
- API client contract (com auth + IR): `11-ui/ui-api-client-contract.md`
- AI Assistant (ir/plan_v1): `11-ui/ui-ai-assistant.md`
- Preview Transform: `11-ui/pages/preview-transform.md`
- State machines & rotas: `11-ui/ui-routes-and-state-machine.md`
- Field catalog: `11-ui/ui-field-catalog.md`
- Component contracts (tipos atualizados): `11-ui/component-specs.md`
- Contract mapping: `11-ui/data-contract-mapping.md`

## Testing
- UI unit tests: `09-testing/ui-unit-test-strategy.md`
- UI contract tests: `09-testing/ui-contract-tests-lite.md`
- Security/auth tests (frontend): `09-testing/security-auth-tests.md`
