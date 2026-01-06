# Release Notes — DSL Reliability

**Release**: DSL Reliability Patch  
**Data**: 2026-01-06

## Problema

- Respostas não parseáveis (não-JSON) e/ou `outputSchema` inválido quebravam o fluxo.
- Modelo alucinava operadores Jsonata e retries repetiam o mesmo erro.
- Retry v2.0 aumentou muito a latência sem melhorar sucesso.

## Correções

1. **OpenRouter: Structured Outputs com enforcement real**
   - `provider.require_parameters=true` e `allow_fallbacks=false`
   - plugin `response-healing` em chamadas não-streaming
2. **LLM retorna somente DSL**
   - `outputSchema` passa a ser inferido a partir do preview (determinístico)
3. **Retry resiliente e com detecção de padrão**
   - parse error também entra no repair loop
   - repetição idêntica → template fallback / prompt mais restritivo
4. **Templates**
   - casos comuns resolvidos sem LLM

## KPIs (metas)

- Taxa de sucesso IT13: **>= 75%** após few-shot + templates  
- Latência média por request: **< 10s** (com fallback rápido)  
- “Non-JSON responses”: **~0%** (com enforcement + healing)

## Flags / Config

Recomendado expor por config (appsettings):
- `AI:DslGeneration:MaxAttempts` (default 2)
- `AI:DslGeneration:EnableTemplateFallback` (default true)
- `AI:DslGeneration:EnableResponseHealing` (default true)
- `AI:DslGeneration:RenamingPolicy` (ExplicitOnly)
