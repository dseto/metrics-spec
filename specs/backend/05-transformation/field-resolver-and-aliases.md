# FieldResolver & Aliases (pt/en) — Resolver campos em JSON variado

## Objetivo
Resolver referências a campos quando o JSON varia:
- nomes diferentes (nome vs name)
- nesting (city vs address.city)
- campos ausentes

## Entradas
- `goal` (texto do usuário)
- `row` (JsonElement object)
- `fieldPointer` (JSON Pointer relativo) OU `fieldName` inferido

## Estratégias (em ordem)
1. JSON Pointer exato (quando fornecido no plano)
2. Match exato por nome de propriedade no nível atual
3. Aliases pt/en (dicionário)
4. Busca em profundidade por chave (DFS), com limite de profundidade (ex.: 4)
5. Fallback: `null` + warning MissingField

## Aliases mínimos (v1)
- nome -> name, fullName
- cidade -> city, cityName, town
- idade -> age
- data -> date, createdAt
- categoria -> category, type
- preço/valor -> price, amount, value
- quantidade -> quantity, qty
- status -> status, state

## Ambiguidade
Se a busca retornar >1 candidate com scores próximos:
- escolher o mais raso (menor depth)
- adicionar warning `AmbiguousField` contendo os candidates (truncados)

## API interna
```csharp
public sealed class FieldResolver
{
    public FieldResolution Resolve(JsonElement row, string desiredNameOrPointer, string goal, string locale);
}
public record FieldResolution(bool Found, JsonElement? Value, string? ResolvedPointer, string? Warning);
```

## Observabilidade
- Logar contagem de MissingField e AmbiguousField por request.
