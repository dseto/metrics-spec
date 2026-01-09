# UI Routes & State Machines — Material 3

Data: 2026-01-08

Este documento define rotas, estado por página e transições para reduzir ambiguidade na implementação.

---

## Rotas (alto nível)

| Route | Page | Guard | Fonte de dados | Ação principal |
|------|------|-------|----------------|----------------|
| /login | LoginPage | — | POST /api/auth/token | Login |
| /dashboard | Dashboard | AuthGuard | GET /api/v1/processes | navegar |
| /processes | ProcessesList | AuthGuard | GET /api/v1/processes | Create (Admin) |
| /processes/:processId | ProcessEditor | AuthGuard | GET/PUT/DELETE /api/v1/processes/:id | Save (Admin) |
| /processes/:processId/versions/:version | ProcessVersionEditor | AuthGuard | GET/PUT /api/v1/processes/:id/versions/:v | Save (Admin) |
| /preview | PreviewTransform | AuthGuard | POST /api/v1/preview/transform | Run preview |
| /connectors | Connectors | AuthGuard | GET/POST /api/v1/connectors | Create (Admin) |

> Admin-only: ações de mutação (Create/Save/Delete) devem exigir `RoleGuard(Admin)` além do AuthGuard.

---

## Comportamento global (HTTP)
- 401: logout automático + redirect `/login`
- 403: snackbar “Sem permissão…” (não derrubar sessão)
- 429: snackbar “Serviço ocupado; tente novamente.”

---

## State machine (exemplo padrão de página)
```ts
type PageState =
  | { kind: 'idle' }
  | { kind: 'loading' }
  | { kind: 'ready' }
  | { kind: 'saving' }
  | { kind: 'error', error: UiError };
```
