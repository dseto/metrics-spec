# Inferência Determinística de JSON Schema a partir do Preview

## 1. Objetivo

Gerar `outputSchema` de forma determinística (sem LLM), com base no resultado real do preview.

## 2. Regras

- Se preview é `null` → `{ "type": "null" }`
- Se preview é `string/number/boolean` → tipo correspondente
- Se preview é `object`
  - `type: "object"`
  - `properties`: para cada key, inferir tipo recursivamente
  - `required`: keys presentes (mínimo viável)
- Se preview é `array`
  - `type: "array"`
  - `items`: inferir pelo primeiro elemento
  - Se array vazio: `items: {}` (ou `type: "object"` genérico), e marcar como “unknown items”

## 3. Ajustes recomendados

- Normalizar `number` como:
  - `integer` se sem parte decimal, senão `number`
- Datas:
  - manter `type: "string"` e opcional `format: "date-time"` se detectar ISO (opcional)

## 4. Critérios de aceite

- Para qualquer preview válido, sempre produzir um JSON Schema parseável.
- `IT13` não deve falhar mais por `outputSchema must be a JSON object`.

## 5. Pseudocódigo

```
Infer(node):
  switch kind(node):
    object:
      props = {}
      req = []
      for (k,v) in node:
         props[k] = Infer(v)
         req.add(k)
      return {type:"object", properties: props, required: req, additionalProperties:false}
    array:
      if len==0: return {type:"array", items:{}}
      return {type:"array", items: Infer(node[0])}
    string: return {type:"string"}
    number: return {type:"number"} // refine to integer optional
    bool: return {type:"boolean"}
    null: return {type:"null"}
```
