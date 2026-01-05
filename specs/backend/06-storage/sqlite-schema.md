### connectors
| column | type | notes |
|---|---|---|
| id | TEXT PK | |
| name | TEXT | |
| baseUrl | TEXT | |
| authRef | TEXT | referência a segredo/config (não guardar segredo aqui) |
| timeoutSeconds | INTEGER | |
| enabled | INTEGER | 0/1 |
| createdAt | TEXT | ISO |
| updatedAt | TEXT | ISO |


### connector_tokens
Tabela 1:1 (connectorId) para armazenar **token criptografado** (não armazenar plaintext).

| column | type | notes |
|---|---|---|
| connectorId | TEXT PK | FK -> connectors(id), ON DELETE CASCADE |
| encVersion | INTEGER | versionamento do payload criptografado (iniciar em 1) |
| encAlg | TEXT | algoritmo (ex.: `AES-256-GCM`) |
| encNonce | TEXT | nonce/IV (base64) |
| encCiphertext | TEXT | ciphertext (base64) |
| createdAt | TEXT | ISO |
| updatedAt | TEXT | ISO |

Observações:
- A chave `METRICS_SECRET_KEY` deve ser **base64 de 32 bytes** (AES-256).
- Tokens **nunca** devem aparecer em logs / exceptions / responses.

### processes
| column | type | notes |
|---|---|---|
| id | TEXT PK | |
| name | TEXT | |
| description | TEXT | nullable |
| status | TEXT | Draft/Active/Disabled |
| connectorId | TEXT FK | -> connectors.id |
| tagsJson | TEXT | JSON array (nullable) |
| createdAt | TEXT | ISO |
| updatedAt | TEXT | ISO |

### process_output_destinations
| column | type | notes |
|---|---|---|
| processId | TEXT FK | -> processes.id |
| idx | INTEGER | 0..n-1 |
| type | TEXT | LocalFileSystem / AzureBlobStorage |
| configJson | TEXT | JSON (ex.: local/basePath ou blob/container/...) |

PK: (processId, idx)

### process_versions
| column | type | notes |
|---|---|---|
| processId | TEXT FK | |
| version | INTEGER | 1..n |
| enabled | INTEGER | |
| method | TEXT | GET/POST/PUT/DELETE |
| path | TEXT | |
| headersJson | TEXT | JSON map (nullable) |
| queryParamsJson | TEXT | JSON map (nullable) |
| dslProfile | TEXT | jsonata/jmespath/custom |
| dslText | TEXT | |
| outputSchemaJson | TEXT | JSON Schema (TEXT) |
| sampleInputJson | TEXT | JSON sample (nullable) |
| createdAt | TEXT | ISO |
| updatedAt | TEXT | ISO |

PK: (processId, version)
