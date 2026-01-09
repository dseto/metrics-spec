# Auth Domain (Frontend)

Data: 2026-01-08

## Objetivo
Definir conceitos mínimos de autenticação/autorização para o frontend (uso interno), alinhado ao backend atual.

## Conceitos
### Access Token (JWT)
- A UI recebe um token (string) ao fazer login.
- A UI envia o token em **todas** as chamadas para `/api/v1/*` via header:
  - `Authorization: Bearer <access_token>`

### Subject (usuário)
- A UI não é responsável por validar assinatura do JWT.
- A UI **pode** ler claims (base64) somente para UX (exibir usuário/roles).  
  O backend é a fonte de verdade (403/401).

### Roles (autorização)
- **Admin**: pode criar/editar/deletar (CRUD) objetos de configuração.
- **Reader**: pode navegar e visualizar (read/preview), sem CRUD.

> Nomes de roles no token: use as strings definidas no backend (ex.: `Metrics.Admin`, `Metrics.Reader`).

## Princípios
- Não guardar senha.
- Token deve ser individual (um token por usuário).
- Em caso de dúvida sobre permissão: deixar o backend decidir e tratar 403 na UI.
