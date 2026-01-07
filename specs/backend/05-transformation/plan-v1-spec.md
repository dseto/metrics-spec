# Plan V1 Spec (Plan IR)

Data: 2026-01-07

## Visão geral

`plan_v1` é um perfil de transformação baseado em um **Plano determinístico (Plan IR)**,
executado server-side pelo `PlanExecutor`.

Ele substitui (no caminho principal) o perfil legacy `jsonata` e permite:
- preview determinístico,
- testes de integração end-to-end,
- fallback por templates quando o LLM falha.

Schema canônico: `specs/shared/domain/schemas/planV1.schema.json`

---

## Estrutura do Plan IR

### Campos de topo
- `recordPath` (string|null): caminho do array de registros a processar
  - exemplos: `/` (root array), `/items`, `/results`, `/results/forecast`
- `steps` (array): pipeline de operações

### Exemplo mínimo (Select fields)
```json
{
  "recordPath": "/items",
  "steps": [
    { "op": "select", "fields": ["id", "name"] }
  ]
}
```

---

## Operações suportadas (mínimo)

> Observação: este documento foca no conjunto **validado por testes de integração**.
> O schema é permissivo para evolução.

### 1) select
Objetivo: projeção de colunas/campos.

Exemplo:
```json
{ "op": "select", "fields": ["id", "nome", "idade"] }
```

Template relacionado:
- T1 (select all)
- T2 (select fields)

### 2) filter
Objetivo: filtrar registros (ex.: `active == true`).

Exemplo (forma típica, engine-defined):
```json
{ "op": "filter", "where": { "field": "active", "eq": true } }
```

Template relacionado:
- T2 (com filtro)

### 3) groupBy
Objetivo: agrupar e agregar.

Exemplo (avg por categoria):
```json
{
  "op": "groupBy",
  "keys": ["category"],
  "aggregates": [
    { "field": "value", "func": "avg", "as": "avgValue" }
  ]
}
```

Template relacionado:
- T5 (GroupBy + Aggregate)

### 4) mapValue
Objetivo: mapear valores (ex.: `A → Active`, `B → Blocked`).

Exemplo:
```json
{
  "op": "mapValue",
  "field": "status",
  "mapping": { "A": "Active", "B": "Blocked" },
  "default": "Unknown"
}
```

### 5) limit
Objetivo: limitar resultados (top N).

Exemplo:
```json
{ "op": "limit", "take": 2 }
```

---

## RecordPath Discovery (heurística)

O RecordPath Discovery é usado para lidar com diferentes formatos de input, por exemplo:
- root array: `[{...}, {...}]`
- wrapper: `{ "items": [...] }`, `{ "results": [...] }`, `{ "data": [...] }`
- nested wrapper: `{ "results": { "forecast": [...] } }`

Algoritmo (alto nível):
1. Tentar root como array
2. Tentar `/items`
3. Tentar `/results`
4. Tentar `/data`
5. Deep scan (primeiro array com `length > 0`)

Heurísticas:
- Preferir paths com mais registros
- Evitar arrays aninhados dentro de records (quando possível)

Código: `src/Api/AI/Engines/PlanV1/RecordPathDiscovery.cs`

---

## Templates (fallback determinístico)

Quando o LLM falha (JSON inválido / schema inválido), o engine seleciona template:

- **T1**: selecionar todos os campos
- **T2**: selecionar campos (e filtro opcional)
- **T5**: group by + aggregate

O template escolhido deve ser registrado em observabilidade (`planSource="template:Tx"`).

---

## Edge cases (recomendado documentar/testar)

- Arrays vazios em `recordPath`
- Campos ausentes / `null`
- Tipos divergentes (ex.: string vs number em aggregate)
- Predicados de filter com valores não-booleanos
- mapValue com chaves não-string (coerção)

> Esses casos devem ser adicionados a `docs/TESTING_PLANV1.md` conforme o suite evoluir.
