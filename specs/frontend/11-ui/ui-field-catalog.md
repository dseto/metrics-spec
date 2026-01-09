# UI Field Catalog (Determinístico)

Data: 2026-01-08

Este documento lista campos por tela e também os ids estáveis (para testes).

---

## Tela: Login
Route: `/login`

| fieldId | path | Tipo UI | Componente | Obrigatório | Validações | Mensagem de erro |
|---|---|---|---|---:|---|---|
| `login.username` | `ui.login.username` | string | Input | sim | trim; min 1; max 200 | Campo obrigatório. |
| `login.password` | `ui.login.password` | string | PasswordInput | sim | min 1; max 200 | Campo obrigatório. |
| `login.submit` | — | action | Button | — | disabled se inválido | — |

---

## AI Assistant (Process Version Editor)

| fieldId | path | Tipo UI | Componente | Obrigatório | Validações | Mensagem de erro |
|---|---|---|---|---:|---|---|
| `ai.goalText` | `ai.goalText` | textarea | Textarea | sim | minLen 10; maxLen 4000 | Descreva o CSV desejado (mín. 10 caracteres). |
| `ai.sampleInputText` | `ai.sampleInputText` | textarea(code) | JsonEditorLite | sim | mustBeValidJson; max 500k | Informe um JSON válido (até 500k). |

### Constraints (Advanced)
| fieldId | path | Tipo UI | Componente | Obrigatório | Validações | Mensagem de erro |
|---|---|---|---|---:|---|---|
| `ai.constraints.maxColumns` | `ai.constraints.maxColumns` | number | NumberInput | sim | min 1; max 200 | Campo obrigatório. |
| `ai.constraints.allowTransforms` | `ai.constraints.allowTransforms` | bool | Checkbox | sim | — | — |
| `ai.constraints.forbidNetworkCalls` | `ai.constraints.forbidNetworkCalls` | bool | Checkbox | sim | — | — |
| `ai.constraints.forbidCodeExecution` | `ai.constraints.forbidCodeExecution` | bool | Checkbox | sim | — | — |

### Hints (opcional)
| fieldId | path | Tipo UI | Componente | Obrigatório | Validações | Mensagem de erro |
|---|---|---|---|---:|---|---|
| `ai.hints.columns` | `ai.hints.columns` | string | Input | não | max 200 | Máx. 200 caracteres. |

### Actions
- `ai.generate` (button): chama `/api/v1/ai/dsl/generate`
- `ai.apply` (button): aplica `dsl` + `outputSchema` no editor

> `dslProfile` não existe mais como campo de UI: é sempre `ir`.

