# Page — Connectors

    Data: 2026-01-01

    ## Route
    - `/connectors`

    ## Purpose
    - CRUD de Connectors (baseUrl, authRef, timeout).

## Referência visual
- `visual/mockups/A_UI_design_mockup_in_Material_Design_3_(Material_.png`
## Layout (responsive)
- Top bar com 'New connector'.
- Tabela com ações edit/delete.
- < md: lista compacta.
## Components
- MsConnectorTable / MsConnectorListCompact
- MsConnectorEditorDialog
- MsErrorBanner

## Data binding (container -> components)
- `connectorsState.items -> MsConnectorTable.rows`
- `connectorsState.loading -> MsConnectorTable.loading`
- `connectorsState.error -> MsErrorBanner.error`
## Actions
- New/Edit abre dialog; Save chama API; snackbar
- Delete -> confirm dialog

## A11y
- Dialog com focus trap; first focus no campo Name.


## API Token (Connector)
O Connector pode armazenar um **API Token** (bearer) de forma segura.

### Regras de UI
- O campo `API Token` é do tipo **password**.
- O token **nunca** deve ser exibido após salvar.
- A lista deve exibir um indicador (ex.: chip) quando `hasApiToken=true`.
- Editar conector:
  - deixar o campo vazio => **não altera** token (mantém)
  - informar um novo token => **substitui**
  - acionar "Limpar token" => **remove** token

### Payload (alinhado ao backend)
- Para alterar/remover token no PUT, a UI deve enviar:
  - `apiTokenSpecified=true`
  - `apiToken=<string>` (substitui) **ou** `apiToken=null` (remove)
- Para manter token: **não enviar** `apiToken` e manter `apiTokenSpecified` ausente/false.

