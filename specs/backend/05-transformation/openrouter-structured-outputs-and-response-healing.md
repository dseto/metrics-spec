# OpenRouter — Structured Outputs + Response Healing (Delta Spec)

## 1. Objetivo

Evitar respostas não-JSON e reduzir defeitos de JSON, garantindo:
- **Formato**: JSON aderente ao schema
- **Parseabilidade**: sem markdown, sem texto misturado, sem JSON truncado (quando possível)

## 2. Request: Structured Outputs

Enviar `response_format` com `type="json_schema"` e `json_schema.strict=true`.

### Exemplo (estrutura)

- `response_format.type = "json_schema"`
- `response_format.json_schema = { name, strict, schema }`

**Schema recomendado (mínimo)**

```json
{
  "type": "object",
  "properties": {
    "dsl": {
      "type": "object",
      "properties": { "text": { "type": "string" } },
      "required": ["text"],
      "additionalProperties": false
    },
    "notes": { "type": "string" }
  },
  "required": ["dsl"],
  "additionalProperties": false
}
```

> Nota: não incluir `outputSchema` aqui. Ele será inferido no servidor.

## 3. Request: Provider Routing (evitar providers que ignoram parâmetros)

Adicionar no body:

```json
"provider": {
  "require_parameters": true,
  "allow_fallbacks": false
}
```

- `require_parameters=true` garante uso apenas de providers que suportam todos os parâmetros do request.
- `allow_fallbacks=false` evita “fallback silencioso” para provider que ignora `response_format`.

## 4. Request: Response Healing plugin

Para requests **não-streaming**, habilitar:

```json
"plugins": [
  { "id": "response-healing" }
]
```

### O que resolve
- Remove markdown wrapper
- Remove texto misturado antes do JSON
- Corrige vírgulas, aspas, colchetes etc.

### Limitações
- Não corrige aderência semântica ao schema (ex.: nome de chave errada).
- Não corrige truncamento por `max_tokens`.

## 5. Critérios de aceite

- `choices[0].message.content` deve ser parseável como JSON em >99% dos casos (idealmente ~100% em testes).
- Se o modelo/provider não suportar `response_format`, o request deve falhar explicitamente (não retornar texto livre).

## 6. Observabilidade

Logar por tentativa:
- `provider.require_parameters`
- `provider.allow_fallbacks`
- `plugins` habilitados
- `openrouter-request-id` (header/response quando disponível)
