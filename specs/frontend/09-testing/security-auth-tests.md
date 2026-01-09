# Frontend Security/Auth Tests (mínimos)

Data: 2026-01-08

## Objetivo
Garantir que as regras de segurança de UI (Auth + Role gating) não regredam.

## Unit tests (recomendado)
1) **AuthInterceptor**
- adiciona `Authorization: Bearer ...` para `/api/v1/*`
- não adiciona token para `/health` e `/api/auth/token`
- em 401: dispara logout + navegação para `/login`

2) **RoleGuard**
- bloqueia rotas admin-only se não houver role Admin
- permite para Admin

3) **PlanExtractor**
- dado `dsl.profile === 'ir'` e `dsl.text` JSON válido → retorna plan object
- se JSON inválido → retorna `null` e não lança exception

## Smoke test manual (dev)
1. Abrir app → redireciona para `/login`.
2. Login válido → navega.
3. Abrir AI Assistant → clicar Generate → request vai para `/api/v1/ai/dsl/generate` com Bearer.
4. Executar Preview → request inclui `plan`.
