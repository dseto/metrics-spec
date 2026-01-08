# Plan V1 Spec (IR)

Data: 2026-01-07

## Visão geral

`ir` é o profile atual de transformação baseado em um **Plano determinístico (PlanV1 IR)**,
executado server-side pelo `PlanExecutor`.

Ele substitui o perfil legacy `jsonata` e permite:
- preview determinístico,
- testes de integração end-to-end estáveis,
- fallback por templates quando o LLM falha,
- reduzir “tribal knowledge” (plano é o contrato executável).

Schema canônico: `specs/shared/domain/schemas/planV1.schema.json`

---

## Onde o `plan` aparece

- Response de `POST /api/v1/ai/dsl/generate` (design-time): `DslGenerateResult.plan`
- Requests de preview/transform (runtime determinístico): `PreviewTransformRequest.plan`

O campo `dsl.text` pode carregar uma representação string do plano, mas **não é o executável**.

---

## Estrutura do plano (alto nível)

```json
{
  "recordPath": "/items",
  "steps": [
    { "op": "select", "fields": ["a","b"] },
    { "op": "filter", "where": { "...": "..." } },
    { "op": "groupBy", "keys": ["host"], "aggregates": [{"op":"avg","field":"cpu"}] },
    { "op": "limit", "take": 100 }
  ]
}
```

- `recordPath` identifica o array de registros a ser processado.
- `steps` é uma lista ordenada (pipeline).

---

## RecordPath Discovery (heurística)

O RecordPath Discovery é usado para lidar com diferentes formatos de input, por exemplo:
- root array: `[Ellipsis, Ellipsis]`
- wrapper: `{ "items": [...] }`, `{ "results": [...] }`, `{ "data": [...] }`
- nested wrapper: `{ "results": { "forecast": [...] } }`

Algoritmo (alto nível):
1. Tentar root como array
2. Tentar `/items`
3. Tentar `/results`
4. Tentar `/data`
5. Deep scan (primeiro array com `length > 0`)

Regras adicionais:
- se nenhum array for encontrado, retornar 400 (input inválido para transformação tabular)
- `recordPath` final deve apontar para um array

---

## Steps suportados (mínimo)

> O schema é permissivo para evoluir; a execução define a semântica.

### `select`
- seleciona campos do registro atual
- pode operar como “select all” se `fields` omitido (dependendo do template)

### `filter`
- filtra registros por predicado (`where`)

### `groupBy` + agregações
- agrupa por chaves
- agrega campos (avg, sum, count, min, max)

### `mapValue`
- projeta/renomeia campo
- pode aplicar transform simples (ex.: multiplicação)

### `limit`
- aplica `take` (top N)

---

## Templates (fallback)

Templates são essenciais para manter determinismo quando o LLM falha:

- **T1**: Select all fields
- **T2**: Select specific fields (+ filtro opcional)
- **T5**: GroupBy + Aggregate

O template escolhido deve ser registrado em observabilidade (ex.: `planSource=template:T2`).

---

## Validação do plano

Antes de executar:
- `plan` deve validar contra `planV1.schema.json`
- `steps` não pode ser vazio
- `recordPath` deve resolver para array

Se falhar:
- retorno 400 (plano inválido) — quando fornecido pelo client
- ou fallback template — quando gerado por AI e inválido

