# Auth Flow & Interceptors (Angular)

Data: 2026-01-08

## Objetivo
Especificar o comportamento de autenticação no frontend, incluindo:
- login/logout
- armazenamento do token
- interceptação HTTP
- guards por rota

---

## Fluxo (alto nível)
1. Usuário acessa rota protegida → se não autenticado → redirect `/login`.
2. Usuário faz login → `POST /api/auth/token` → salva `access_token`.
3. Interceptor adiciona Bearer em `/api/v1/*`.
4. Em 401: logout automático (limpar token) + redirect `/login`.
5. Em 403: manter sessão; mostrar erro de permissão (snackbar).

---

## Angular building blocks

### AuthService
- `login(username, password)`
- `logout()`
- `getToken()`
- `isAuthenticated()`
- `getRoles()` (opcional; UX)

### TokenStorage
- Ver: `../06-storage/token-storage.md`

### AuthInterceptor
Regras:
- Para URLs que começam com `/api/v1/`:
  - se houver token: adicionar `Authorization: Bearer <token>`
- Para `/health` e `/api/auth/token`:
  - **não** adicionar Bearer
- Ao receber 401:
  - limpar token
  - navegar para `/login`
  - snackbar: “Sessão expirada. Faça login novamente.”
- Ao receber 403:
  - snackbar: “Sem permissão para esta ação.”

### Guards
- `AuthGuard`: bloqueia rotas protegidas se `!isAuthenticated()`.
- `RoleGuard`: bloqueia rotas/actions admin-only se não tiver role de Admin.

---

## Padrão de UI/UX
- Header exibe usuário/roles (se disponíveis).
- Logout sempre disponível quando autenticado.
