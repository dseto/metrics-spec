# Environment Configuration (Dev / Test / Prod)

Data: 2026-01-07

Este documento define um padrão de configuração para o backend, com foco em:
- reduzir “tribal knowledge”
- permitir reproducibilidade em dev/test
- manter um baseline de segurança (mesmo em rede interna)

---

## 1) Premissas

- A API roda em rede interna, mas **não deve confiar** apenas em CORS.
- Mesmo para uso interno, autenticação é necessária para:
  - auditabilidade (quem chamou o quê)
  - controle de perfis (admin vs reader)
  - mitigação de abuso acidental

---

## 2) Variáveis de ambiente (principais)

| Variável | Exemplo | Obrigatória | Observação |
|---------|---------|-------------|-----------|
| `METRICS_OPENROUTER_API_KEY` | `sk-or-v1-...` | Não | Só se AI estiver habilitada e você quiser LLM real |
| `METRICS_SQLITE_PATH` | `./data/config.db` | Não | Pode ter default |
| `CORS_ORIGINS` | `http://localhost:4200` | Não | Para permitir front Angular |
| `Auth__Mode` | `LocalJwt` | Não | Modo default para dev |
| `Auth:LocalJwt:EnableBootstrapAdmin` | `true` | Dev/Test | Habilita login bootstrap |
| `METRICS_SECRET_KEY` | `...` | Depende | Chave usada pelo módulo de auth (se aplicável) |

> Nomes exatos podem variar conforme o projeto; a regra é: **documentar tudo que é necessário**
> para reproduzir o ambiente.

---

## 3) Arquivos `.env`

- Permitido em dev/test
- Nunca comitar secrets
- Ideal: `.env` na raiz do repo (os testes tentam carregar automaticamente)

Exemplo:

```env
CORS_ORIGINS=http://localhost:4200
METRICS_OPENROUTER_API_KEY=sk-or-v1-...
Auth__Mode=LocalJwt
Auth__LocalJwt__EnableBootstrapAdmin=true
```

---

## 4) Matriz por ambiente

### Dev (local)
- Auth: `LocalJwt` com bootstrap admin habilitado
- CORS liberado para `localhost:4200`
- AI:
  - opcional (habilitar somente com key)
- SQLite:
  - path local (`./data/...`)

### Test (CI/local)
- Auth: `LocalJwt` (bootstrap admin pode ser habilitado no TestHost)
- CORS: irrelevante para tests server-side, mas deve existir teste cobrindo policy
- AI:
  - testes LLM isolados por trait
  - CI pode rodar sem key e ignorar `Category=LLM`

### Prod
- Auth: provider corporativo (Okta/Entra) **ou** modo interno endurecido
- Bootstrap admin: DESABILITADO
- CORS: lista restrita de origens internas
- AI:
  - habilitar apenas com policy de segurança e rate limit
  - logs/audit obrigatórios

---

## 5) Checklist de segurança (mínimo viável)

- [ ] Endpoints de AI exigem Bearer token
- [ ] Rate limit para endpoints sensíveis (auth/ai)
- [ ] Logs com `correlationId` e `subject`
- [ ] Secrets fora do repo (KeyVault/secret store em produção)
- [ ] CORS restrito (não confiar como “segurança”)

