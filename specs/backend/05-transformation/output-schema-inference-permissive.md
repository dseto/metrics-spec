# OutputSchemaInferer — modo Permissivo (PlanEngine)

## Objetivo
Evitar regressões em validação quando os itens variam (campos opcionais, nulls, tipos divergentes).

## Regras (v1 - permissivo)
- `required`: NÃO gerar (ou sempre vazio)
- `additionalProperties`: true em objetos
- Para arrays de objetos:
  - inferir `items.properties` fazendo merge de todas as chaves observadas nos N primeiros itens (N=50 default)
  - tipos: coletar conjunto de tipos observados; se >1, usar `oneOf` simples OU escolher tipo mais genérico:
    - string/number -> string (se mixed) + warning TypeCoercion
    - number/integer -> number
    - null + T -> permitir null (type union)
- Para scalars: schema = { "type": "<tipo>" }

## Implementação sugerida
- `InferSchema(JsonElement output, SchemaMode mode=Permissive)`
- `InferArrayItemsSchema(JsonElement array, int maxSamples=50)`
- `MergeObjectSchemas(...)`

## Observabilidade
- número de warnings TypeCoercion
- contagem de campos inferidos
