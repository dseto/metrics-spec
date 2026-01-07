# Engine Routing & Compat — /api/v1/ai/dsl/generate

## Objetivo
Adicionar um novo motor (`plan_v1`) sem quebrar o legacy.

## Request (incremental)
Adicionar campo opcional:

```json
{
  "engine": "legacy" | "plan_v1" | "auto"
}
```

### Default
- Se `engine` não vier: usar `Ai:DslEngineDefault` (config), default inicial `legacy`.

### Config (appsettings)
```json
{
  "Ai": {
    "DslEngineDefault": "legacy",
    "DslEngineAutoEnabled": true,
    "IncludePlanInResponseByDefault": false
  }
}
```

## Response (compat)
Manter resposta existente.
Adicionar campo opcional `plan` apenas quando:
- query string `includePlan=true` **ou**
- config `IncludePlanInResponseByDefault=true`

Exemplo:
```json
{
  "dsl": { "profile": "jsonata", "text": "..." },
  "outputSchema": { ... },
  "previewCsv": "...",
  "plan": { ... } // opcional
}
```

## Modo `auto`
- Tentar `plan_v1` quando:
  - RecordPathDiscovery encontra um arrayPath com confiança >= 0.75
  - Goal é classificado como coberto (extract/filter/sort/group/compute/mapValue)
- Caso contrário: fallback para legacy.

## Observabilidade
Logar (Info):
- correlationId / requestId
- engineSelected (legacy|plan_v1)
- recordPath escolhido e score
- warnings gerados (contagem por tipo)
- latência total e número de chamadas LLM

## Erros
- Erro em plan_v1 com caso coberto:
  - tentar fallback para legacy (somente em `engine=auto`)
- Erro em plan_v1 com `engine=plan_v1`:
  - retornar 400 com `NeedClarification` quando ambíguo
  - retornar 422 com `PlanValidationFailed` quando plano inválido
  - retornar 500 apenas em falhas internas
