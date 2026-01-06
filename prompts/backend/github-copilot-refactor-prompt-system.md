# Prompt (GitHub Copilot) — Refatorar Prompt System (reduzir overload + few-shot)

Objetivo: reduzir o prompt system (150+ linhas) para ~50-70 linhas, adicionando few-shot mínimo.

## Regras
- Manter regras CRÍTICAS:
  - raiz implícita (não usar $.)
  - ordenação com ^()
  - proibir $group (usar $distinct + $sum)
  - não traduzir nomes de campos sem pedido explícito
- Incluir 3 exemplos few-shot:
  1) extraction + rename (PT)
  2) group by + sum (EN)
  3) sort asc/desc (PT/EN)

## Output
- Atualizar o método que monta o system prompt em `HttpOpenAiCompatibleProvider.cs`
- Garantir que o prompt final caiba confortavelmente no context window, mesmo com sample input.
