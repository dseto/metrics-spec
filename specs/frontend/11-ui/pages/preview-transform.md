# Page — Preview Transform

Data: 2026-01-08

## Route
- `/preview`

## Objetivo
Tela dedicada para testar transformação (sem salvar versão).

## Endpoint
- `POST /api/v1/preview/transform`

## Request
```json
{
  "sampleInput": { ... },
  "dsl": { "profile": "ir", "text": "{...JSON string...}" },
  "outputSchema": { ... },
  "plan": { ... } // preferido quando disponível
}
```

### Regra do `plan`
- Se a UI tiver `plan` em memória (ex.: recém gerado pelo AI Assistant), enviar `plan`.
- Se não tiver e `dsl.profile === "ir"`:
  - tentar `plan = JSON.parse(dsl.text)`
  - se falhar, enviar `plan: null` e tratar erro retornado.

## Response (alto nível)
- `isValid`:
  - `true`: renderizar output + `previewCsv` (quando existir)
  - `false`: renderizar errors (lista com `path` e `message`)
- `output`: objeto/array transformado (quando válido)
- `previewCsv`: string (quando gerável)

## Layout (responsive)
- 3 col (>= lg): Input | DSL/Schema/Plan | Output/CSV
- < lg: tabs

## Componentes sugeridos
- `MsPreviewWorkbench`
  - `MsJsonEditorLite` (Input)
  - `MsJsonEditorLite` (DSL - read-only)
  - `MsJsonEditorLite` (Schema - read-only)
  - `MsJsonEditorLite` (Plan - read-only)
  - `MsPreviewPanel` (CSV + tabela)

## Estados
- idle
- running (loading)
- success
- invalid (validation errors, HTTP 200)
- failed (HTTP error)

## Erros
- 401: logout + redirect `/login`
- 403: snackbar “Sem permissão…”
- 400: request inválido (ex.: JSON schema inválido) → banner com detalhes
