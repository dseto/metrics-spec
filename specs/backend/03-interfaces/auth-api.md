# Delta — Interfaces: Auth API

## Endpoint (LocalJwt)
### POST /api/auth/token
Ativo somente quando `Auth.Mode=LocalJwt`.

Request:
```json
{ "username": "daniel", "password": "secret" }
```

Response 200:
```json
{ "access_token": "eyJ...", "token_type": "Bearer", "expires_in": 3600 }
```

Erros:
- 401 `AUTH_UNAUTHORIZED` (credenciais inválidas / usuário inativo)
- 429 `AUTH_RATE_LIMITED` (rate limit ou lockout)

## Endpoint opcional (recomendado)
### GET /api/auth/me
Protegido por `Reader`.
Retorna:
```json
{ "sub": "daniel", "roles": ["Metrics.Admin"], "displayName": "Daniel", "email": "..." }
```
Motivação: evitar parse de JWT no frontend.

## Admin endpoints (opcionais)
Se desejar gestão simples sem mexer no DB manualmente:
Base: `/api/admin/auth/users` (Admin)
- POST create user + roles
- PUT enable/disable + update profile + roles
- POST reset-password

Regras:
- nunca retornar password_hash
- auditar alterações (quem fez o quê)


## Detalhes importantes (implementação observável)

### Username case-insensitive
- Login e operações admin devem tratar `username` como **case-insensitive** para lookup.
- Regra normativa para queries: `LOWER(username) = LOWER(@username)` (evitar normalizar o parâmetro no client).

### Buscar usuário por username (Admin)
Novo endpoint (Admin only) para evitar ambiguidade com o endpoint por `id`:

**GET /api/admin/auth/users/by-username/{username}**
- 200: retorna `UserDto`
- 404: usuário não encontrado
- 401/403: conforme políticas (JWT + role Admin)

Observação:
- `GET /api/admin/auth/users/{id}` continua sendo lookup por **UUID/id interno**, não por username.

