# TESTING_PLANV1

Data: 2026-01-07

## Objetivo

Documentar o **padrão de testes de integração (E2E)** para fluxos `plan_v1`,
evitando dependência de conhecimento tácito (“tribal knowledge”).

---

## Padrão de teste (integration)

1) **Gerar DSL/Plan**
- Chamar `POST /api/v1/ai/dsl/generate` com engine `plan_v1`
- Validar:
  - `result.dsl.profile == "plan_v1"`
  - `result.plan != null`

2) **Executar preview**
- Chamar `POST /api/v1/preview/transform` enviando:
  - `sampleInput`
  - `dsl` (do generate)
  - `outputSchema` (do generate)
  - `plan` (do generate)

3) **Assert**
- `isValid == true`
- (opcional) validar CSV gerado e/ou rows retornadas

---

## Helper recomendado

Um helper `ExecuteTransformAsync(sampleInput, dslResult)` deve:
- montar o request incluindo `plan`
- retornar `PreviewTransformResponseDto`

---

## Cobertura mínima recomendada

### Templates (determinísticos)
- T1: Select all fields
- T2: Select fields (+ filter)
- T5: GroupBy + Aggregate

### Inputs variados
- Root array: `[{...}]`
- Wrapper: `{ "items": [...] }`
- Wrapper: `{ "results": [...] }`
- Nested wrapper: `{ "results": { "forecast": [...] } }`

### Casos de erro
- Plan inválido (schema) → 400
- Execução falha (field inexistente) → 400
- Schema de output não bate com rows → 200 com `isValid=false`

---

## Notas sobre LLM real

Em ambientes com LLM real, é esperado que:
- algumas respostas não sejam JSON válido,
- alguns planos sejam inválidos,
- fallback por templates seja acionado com frequência.

Logo, recomenda-se:
- manter testes determinísticos por template (estáveis),
- isolar testes “real LLM” e permitir `Skip` quando necessário.
