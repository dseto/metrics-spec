# Release Notes — Frontend Spec Deck

Data: 2026-01-08
Versão: frontend-align-ir-auth-v1

## Principais mudanças
- `/api/*` → `/api/v1/*` para endpoints de negócio e AI (exceto `/api/auth/token`).
- AI Assistant:
  - `dslProfile` fixo em `ir`
  - `constraints` obrigatórias (com defaults)
  - response inclui `plan` e UI deve preservá-lo para preview.
- Preview/Transform:
  - request aceita `plan` (preferir enviar sempre que possível).
- Autenticação mínima (LocalJwt):
  - `/login`, interceptor Bearer, logout automático em 401.
- Controle de acesso Admin/Reader:
  - UI esconde ações admin-only e aplica guards.

## Breaking changes (UI)
- Remover seletor de `dslProfile` (jsonata/jmespath).
- DSL editor deve tratar DSL como **JSON (IR/plan)**, não expressão.

