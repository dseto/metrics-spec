# UI ↔ API Contract Mapping

Data: 2026-01-08

Base (fonte de verdade):
- OpenAPI: `specs/shared/openapi/config-api.yaml`
- Schemas: `specs/shared/domain/schemas/*.schema.json`

## Auth
- POST `/api/auth/token`

## Process
- GET/POST `/api/v1/processes`
- GET/PUT/DELETE `/api/v1/processes/{id}`

## ProcessVersion
- POST `/api/v1/processes/{id}/versions`
- GET/PUT `/api/v1/processes/{id}/versions/{version}`

## Connector
- GET/POST `/api/v1/connectors`
- GET/PUT/DELETE `/api/v1/connectors/{connectorId}`

## Preview
- POST `/api/v1/preview/transform`
  - request inclui `plan` quando disponível (preferido)

## AI
- POST `/api/v1/ai/dsl/generate`
  - requer Bearer
  - `dslProfile` fixo `ir`
