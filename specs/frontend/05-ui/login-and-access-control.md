# UI — Login & Access Control

Data: 2026-01-08

## Rota
- `/login`

## Campos
- `username` (required)
- `password` (required)

## Ações
- Submit:
  - chama `POST /api/auth/token`
  - em sucesso:
    - salvar token
    - navegar para `/dashboard` (ou rota inicial do app)
  - em 401:
    - mostrar “Usuário ou senha inválidos.”
    - limpar campo password
  - em 429:
    - mostrar “Muitas tentativas. Tente mais tarde.”

## Controle de acesso (UX)
- **Admin-only**:
  - botões e menus de Create/Edit/Delete devem aparecer só para Admin
- **Reader**:
  - pode visualizar listas, detalhes e executar preview, mas sem CRUD

> Importante: isso é só UX. O backend deve aplicar 403.
