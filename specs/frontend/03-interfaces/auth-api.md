# Auth API (Frontend contract)

Data: 2026-01-08

## Endpoint: obter token
- `POST /api/auth/token`
- Request JSON:
```json
{ "username": "admin", "password": "ChangeMe123!" }
```

- Response JSON (mínimo garantido):
```json
{ "access_token": "eyJhbGciOi..." }
```

> Campos adicionais podem existir, mas a UI **só depende** de `access_token`.

## Erros
- 401: credenciais inválidas → UI deve mostrar mensagem e manter usuário na tela de login.
- 429: rate limit de tentativas → UI deve orientar a tentar mais tarde.
