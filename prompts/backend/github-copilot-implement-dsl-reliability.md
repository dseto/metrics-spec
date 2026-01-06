# Prompt (GitHub Copilot) — Implementar Confiabilidade da Geração de DSL (BACKEND)

Você é um agente de implementação no repositório existente.  
Objetivo: corrigir a geração de DSL Jsonata por LLM (OpenRouter), garantindo respostas parseáveis e DSL válida.

## Contexto
- Linguagem: C#/.NET
- Provedor: OpenRouter Chat Completions
- Arquivo chave: `src/Api/AI/HttpOpenAiCompatibleProvider.cs`
- Endpoint chave: `src/Api/Program.cs` (ou controller equivalente)
- Testes: `tests/Integration.Tests/IT13_LLMAssistedDslFlowTests.cs`

## Requisitos obrigatórios

### A) OpenRouter request hardening
1. Enviar `response_format` com `type="json_schema"`, `json_schema.strict=true`.
2. Adicionar `plugins: [{ id: "response-healing" }]` (apenas non-streaming).
3. Adicionar `provider: { require_parameters: true, allow_fallbacks: false }`.

### B) LLM output mínimo
- Ajustar o schema do structured output para aceitar SOMENTE:
```json
{ "dsl": { "text": "..." }, "notes": "optional" }
```
- Remover `outputSchema` do retorno da LLM (será inferido no servidor).

### C) Parse resiliente
- Implementar função `TryParseJsonObject(string content, out JsonDocument doc)` que:
  - remove markdown ```json
  - extrai substring do primeiro '{' ao último '}'
  - tenta parsear 2-3 variações
  - retorna erro classificado se falhar

### D) Retry inteligente (MaxAttempts=2 default)
- Sempre fazer retry inclusive para erros de parse.
- Classificar erro por categoria (ParseJson, Contract, JsonataSyntax, JsonataEval).
- Se erro repetir (mesma categoria + mesma DSL normalizada) em 2 tentativas, parar retry e ir para template fallback.

### E) Template fallback
- Criar um `DslTemplateLibrary` com templates T1..T5 (ver `templates/dsl-template-library.md`).
- Criar um `DslTemplateMatcher` que seleciona template por heurística de keywords.
- Se match, gerar DSL sem LLM.

### F) Inferência determinística de `outputSchema`
- Após preview, inferir JSON Schema e retornar no response final.
- Se preview falhar, outputSchema não deve ser gerado e deve acionar repair/fallback.

### G) Política de renomeação
- Não traduzir nomes de campos automaticamente (ex.: date->data) a menos que o prompt peça explicitamente.
- Enforce essa regra no prompt system e nos templates.

## Entregáveis
- Código implementado e compilando
- IT13 atualizado/passa conforme policy
- Logs com provider/model/request-id/attempt/errorCategory

## Não fazer
- Não criar novas dependências externas pesadas.
- Não alterar contratos públicos sem atualizar OpenAPI + testes.

Implemente em pequenos commits lógicos.
