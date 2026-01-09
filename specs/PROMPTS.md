# Prompts (GitHub Copilot)

## Prompt — Implementar ajustes no FRONTEND (Angular) para Auth + IR (PlanV1)

Você é um agente de implementação no repositório do frontend Angular já funcional.
Seu objetivo é **implementar** as alterações descritas neste spec deck (delta), alinhando o frontend ao backend atual.

### Regras obrigatórias
1) **Leia os arquivos de spec abaixo antes de codar** e siga os detalhes (campos, fluxos, erros, rotas).
2) Faça mudanças pequenas e incrementais, garantindo build/compilação a cada etapa.
3) Não invente endpoints ou DTOs: use os caminhos e estruturas especificadas.
4) Caso encontre divergência com o código atual, ajuste o código para cumprir a spec; se algo estiver ambíguo, crie comentário `// SPEC_TODO:` apontando o arquivo/linha da spec.

### Arquivos de spec que você DEVE consultar
- `specs/frontend/11-ui/ui-api-client-contract.md`
- `specs/frontend/11-ui/ui-ai-assistant.md`
- `specs/frontend/11-ui/pages/preview-transform.md`
- `specs/frontend/11-ui/data-contract-mapping.md`
- `specs/frontend/11-ui/ui-routes-and-state-machine.md`
- `specs/frontend/11-ui/ui-field-catalog.md`
- `specs/frontend/02-domain/auth-domain.md`
- `specs/frontend/03-interfaces/auth-api.md`
- `specs/frontend/04-execution/auth-flow-and-interceptors.md`
- `specs/frontend/05-ui/login-and-access-control.md`
- `specs/frontend/06-storage/token-storage.md`
- `specs/frontend/09-testing/security-auth-tests.md`

### Entregáveis no código
#### A) Infra de Auth
- Criar rota `/login` + página de login.
- Implementar `AuthService` com:
  - `login(username,password) -> POST /api/auth/token`
  - armazenar `access_token`
  - `logout()`
  - `getToken()` e `isAuthenticated()`
- Implementar `TokenStorage` conforme spec (localStorage preferencial, com fallback memory).
- Implementar `AuthInterceptor`:
  - adicionar `Authorization: Bearer <token>` em **todas** as chamadas para `/api/v1/*`
  - em 401: limpar token, redirecionar para `/login`, exibir snackbar “Sessão expirada. Faça login novamente.”
  - em 403: manter sessão e exibir snackbar “Sem permissão para esta ação.”
- Implementar `AuthGuard` para rotas protegidas e `RoleGuard` para admin-only (ver roles na spec).

#### B) Alinhar base URL e endpoints
- Atualizar qualquer referência `/api/...` para `/api/v1/...` nos services.
- Garantir que `/health` continue livre (sem Bearer).
- Garantir que `/api/auth/token` continue em `/api/auth/token` (sem `/v1`).

#### C) AI Assistant — IR/PlanV1
- Remover seletor `dslProfile` (jsonata/jmespath). Agora é fixo `ir`.
- Implementar UI de **constraints obrigatórias** (com defaults) e enviar no request.
- Implementar request `POST /api/v1/ai/dsl/generate` conforme spec.
- Processar response e permitir **Apply** para preencher `dsl` + `outputSchema` no editor.
- Preservar `plan` retornado em estado UI para ser usado no Preview/Transform.
- Se abrir versão já salva e não houver `plan` em memória, tentar derivar `plan` fazendo `JSON.parse(dsl.text)` quando `dsl.profile === 'ir'`.

#### D) Preview/Transform — enviar Plan
- Atualizar o client do preview para `POST /api/v1/preview/transform`.
- Montar request com:
  - `sampleInput` (obj)
  - `dsl` (profile + text)
  - `outputSchema`
  - `plan` (se disponível; caso contrário, tentar parse do `dsl.text` quando profile `ir`)
- Tratar `isValid=false` como erro de validação (não exception). Renderizar errors e CSV preview quando houver.

#### E) Testes mínimos
- Unit tests:
  - `AuthInterceptor` adiciona Bearer e faz logout em 401.
  - `RoleGuard` bloqueia admin-only para Reader.
  - `PlanExtractor` (função util) parseia `dsl.text` para `plan` quando possível.

### Critérios de aceite (DoD)
- Usuário consegue logar e navegar.
- Chamadas para `/api/v1/ai/dsl/generate` funcionam com Bearer.
- Preview/Transform funciona e inclui `plan` sempre que possível.
- `jsonata`/`jmespath` não aparecem mais na UI.
- Build e testes passam.

