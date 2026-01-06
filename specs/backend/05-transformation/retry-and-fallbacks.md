# Retry & Fallbacks (Delta Spec)

## 1. Princípios

- Retry só é útil se:
  - muda o prompt de forma significativa, OU
  - muda a estratégia (template fallback), OU
  - troca modelo/provider

Repetir a mesma tentativa 3x com o mesmo erro é desperdício e piora UX.

## 2. Categorias de erro (classificação)

1) `LLM_RESPONSE_NOT_JSON`
- `choices[0].message.content` não parseia como JSON
- ação: aplicar “extract JSON object” + se falhar, retry com “Return ONLY JSON”

2) `LLM_CONTRACT_INVALID`
- JSON parseia, mas falta `dsl.text` ou está vazio
- ação: retry com schema reminder

3) `JSONATA_SYNTAX_INVALID`
- parser/eval falha por sintaxe (ex.: `$group`)
- ação: repair hint específico (proibir `$group`, usar `$distinct + $sum`)

4) `JSONATA_EVAL_FAILED`
- sintaxe ok, mas paths inválidos / campos inexistentes
- ação: repair hint com “validate sampleInput field names”

5) `TIMEOUT`
- reduzir max_attempts e/ou usar template

## 3. Detecção de repetição

- Hash do par `(errorCategory, normalizedErrorMessage, normalizedDsl)`
- Se repetiu 2x:
  - parar retries do mesmo tipo
  - entrar em template fallback OU retornar erro com instrução ao usuário

## 4. Estratégia recomendada (default)

- `MaxAttempts = 2`
- Attempt 1: template match → se não, LLM
- Attempt 2: repair com hint específico (curto)
- Se falhar:
  - template fallback (se habilitado)
  - erro final (com mensagem clara)

## 5. Critérios de aceite

- Nenhum teste pode demorar > 15s sem justificativa
- Test 2 (Aggregation) não pode repetir `$group` 3x; deve fallbackar após repetição
