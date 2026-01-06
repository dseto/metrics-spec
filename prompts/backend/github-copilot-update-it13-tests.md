# Prompt (GitHub Copilot) — Atualizar IT13 para a policy de renomeação + outputSchema inferido

Objetivo: ajustar `IT13_LLMAssistedDslFlowTests` para refletir:
1) `outputSchema` agora é inferido no servidor (não depende da LLM)
2) Campo `date` NÃO deve virar `data` a menos que o prompt peça

## Tarefas
- Em WeatherForecast_RealWorldPrompt:
  - Ajustar asserts para esperar `"date"` no output (a menos que o prompt diga “rename date to …”)
- Em SimpleExtraction:
  - Remover fragilidade que assume `outputSchema` vindo da LLM; validar estrutura inferida
- Adicionar asserts de latência/attempts:
  - Não permitir 3 tentativas idênticas em Aggregation (deve fallback)

## Resultado esperado
- IT13 passa de forma determinística.
