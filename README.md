# Delta Spec Deck — Confiabilidade da Geração de DSL (Jsonata)

**Data**: 2026-01-06  
**Objetivo**: Corrigir o “coração” da solução: geração de DSL Jsonata via LLM, garantindo **resposta sempre parseável**, redução de alucinações e **saída consistente** (incluindo `outputSchema`).

Este delta spec deck endereça diretamente os sintomas observados:
- Resposta da LLM **não-JSON** / `outputSchema` inválido → pipeline quebra antes do retry
- Alucinação de sintaxe Jsonata (`$group`, `[date]` para ordenar) e retries repetidos
- Regressão com retry v2.0 (latência alta e 0% de sucesso)

## O que muda (visão geral)

1) **Structured Outputs + Response Healing (OpenRouter)**  
- Enviar `response_format` com `type="json_schema"` e `strict=true`  
- Habilitar plugin `response-healing` via `plugins: [{id:"response-healing"}]`  
- Roteamento: `provider.require_parameters=true` e `allow_fallbacks=false`

2) **LLM não gera mais `outputSchema`**  
- LLM retorna apenas `dsl.text` (+ opcional `notes`)  
- Backend executa preview e **infere `outputSchema` determinísticamente** a partir do JSON resultante

3) **Retry inteligente e rápido (sem “loop inútil”)**  
- Retry sempre aciona, inclusive se a resposta **não parseia**
- Detecta repetição do mesmo erro → muda estratégia (template fallback / repair específico)

4) **Template fallback para casos comuns**  
- Extraction/rename, sort, filter, group+sum  
- Garante alto “success floor” mesmo com modelo fraco

5) **Política de renomeação de campos**  
- Não traduz/renomeia automaticamente nomes (ex.: `date` → `data`) **a menos que o usuário peça explicitamente**.

## Como aplicar

1. Copie os arquivos desta pasta para dentro do repositório (mantendo a estrutura).
2. Siga `specs/backend/05-transformation/dsl-generation-reliability.md` para implementar no backend.
3. Rode `IT13_LLMAssistedDslFlowTests` e verifique KPIs em `RELEASE_NOTES.md`.

## Entregáveis

- Especificações detalhadas (backend)
- Biblioteca de templates (documentação + catálogo)
- Prompts para GitHub Copilot implementar e ajustar testes

