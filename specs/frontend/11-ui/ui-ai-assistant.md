# UI — AI Assistant (Gerar DSL/Schema) — Profile `ir` (PlanV1)

Data: 2026-01-08

## Objetivo
Permitir que o usuário descreva o CSV desejado em linguagem natural e gerar:
- `dsl` (profile `ir` + `text` JSON)
- `outputSchema`
- `plan` (objeto) para preview/transform (quando retornado)

## Endpoint
- `POST /api/v1/ai/dsl/generate`
- Requer `Authorization: Bearer <token>`

## Campos (UI)
### Obrigatórios
- `goalText` (textarea): descrição do CSV (min 10, max 4000)
- `sampleInputText` (textarea code): JSON de exemplo (parse obrigatório)
- `constraints` (Advanced section; defaults):
  - `maxColumns` (number) default 50 (min 1, max 200)
  - `allowTransforms` (checkbox) default true
  - `forbidNetworkCalls` (checkbox) default true (deve permanecer true no mínimo)
  - `forbidCodeExecution` (checkbox) default true (deve permanecer true no mínimo)

### Opcionais
- `hints.columns` (text): lista de colunas desejadas (ex.: "id,name,total")
- `existingDsl` / `existingOutputSchema`: para iteração (se UI suportar “refinar”)

> `dslProfile` NÃO é campo de UI. A UI sempre envia `dslProfile: "ir"`.

## Request (montagem)
1) `sampleInput = JSON.parse(sampleInputText)`
2) `request: DslGenerateRequest` conforme `11-ui/ui-api-client-contract.md`

Exemplo:
```json
{
  "goalText": "Gerar CSV com timestamp, hostName e cpuUsagePercent",
  "sampleInput": { "result": [ { "timestamp":"...", "host":{"name":"a"}, "cpu":{"pct":42} } ] },
  "dslProfile": "ir",
  "constraints": {
    "maxColumns": 50,
    "allowTransforms": true,
    "forbidNetworkCalls": true,
    "forbidCodeExecution": true
  },
  "hints": { "columns": "timestamp,hostName,cpuUsagePercent" }
}
```

## Response (render)
Renderizar 3 painéis (read-only):
- **DSL (ir)**: mostrar `dsl.text` (JSON string) formatado quando possível
- **Plan**: mostrar `plan` (se vier) e manter em memória para preview
- **Output Schema**: JSON formatado
- (Opcional) **Example Rows**: grid/table

## Apply
Ao clicar **Apply**:
- Preencher no Process Version Editor:
  - `version.dsl.profile = "ir"`
  - `version.dsl.text = <dsl.text>`
  - `version.outputSchema = <outputSchema>`
- Persistir também (state UI, não API):
  - `ui.lastGeneratedPlan = result.plan` (para preview imediato)

## Uso do `plan` no preview
- Se `result.plan` existir, enviar em `POST /api/v1/preview/transform` (ver page spec).
- Se o usuário abrir uma versão persistida que não tem `plan` em memória:
  - Se `dsl.profile === "ir"`, tentar `JSON.parse(dsl.text)` para derivar `plan`.
  - Se parse falhar, enviar `plan=null` e tratar erro retornado.

## Erros
- 401: redirect `/login`
- 403: snackbar “Sem permissão…”
- 503 `AI_DISABLED`: banner “IA desabilitada nesta instalação”
- 503 `AI_PROVIDER_UNAVAILABLE`: “Serviço de IA indisponível”
- 429: “Serviço ocupado; tente novamente.”
- 400 validação (goal curto / constraints inválidas): apontar campos na UI
