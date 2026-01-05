# Runtime Configuration (Frontend)

Data: 2026-01-05

Objetivo: permitir alterar **API base URL** e flags (AI enablement, etc.) **no deploy**, sem rebuild do Angular.

---

## Arquivos

### `src/assets/config.json` (dev)
Arquivo carregado por HTTP no startup da UI.

Exemplo:
```json
{
  "apiBaseUrl": "http://localhost:8080/api/v1",
  "aiEnabled": true
}
```

### `src/assets/config.template.json` (CI/CD)
Template com placeholders para substituição em deploy:
- `apiBaseUrl`
- flags opcionais

---

## Carregamento no startup

### RuntimeConfigService
- Deve carregar `/assets/config.json`
- Deve expor `apiBaseUrl` para os ApiClients/Services

### APP_INITIALIZER
- A aplicação só inicia após o config ser carregado (fail fast com mensagem amigável se não carregar)

---

## Docker / Nginx (runtime)
Quando empacotado com Nginx:

### `docker-entrypoint.sh`
- deve gerar `config.json` a partir de `config.template.json` usando `envsubst`:
```bash
envsubst < config.template.json > config.json
```

### Regras
- Não commit de URLs de produção no Git
- Mudança de endpoint deve exigir **apenas** troca de variável/env no deploy
