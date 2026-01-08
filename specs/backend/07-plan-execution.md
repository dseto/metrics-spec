# Plan V1 (IR) Execution in Preview/Transform (Server-side)

Data: 2026-01-07

## Objetivo

Padronizar e documentar o fluxo **implementado** para executar transformações determinísticas
quando o DSL profile é **`ir`** (PlanV1 IR).

Este fluxo existe para:
- eliminar dependência de `jsonata`,
- permitir execução determinística (PlanExecutor),
- suportar fallback por templates quando LLM falha,
- reduzir “tribal knowledge” (contratos + erros + observabilidade).

---

## Contrato do Preview/Transform

Request (alto nível):
- `sampleInput` (JSON)
- `outputSchema` (JSON Schema)
- `plan` (PlanV1)

> `dsl` pode existir para auditoria/display, mas o executável é `plan`.

---

## Fluxo canônico (runtime determinístico)

1) Resolver `recordPath` no `sampleInput`
2) Executar `steps` com `PlanExecutor` → produzir `rowsArray`
3) Validar `rowsArray` contra `outputSchema`
4) Gerar CSV determinístico (ordem e headers consistentes)

---

## Tratamento de erros

### Request inválido (400)
- `plan` ausente ou inválido
- `recordPath` não resolve para array
- `outputSchema` inválido

### Preview inválido (200 + isValid=false)
- `rowsArray` é array, mas viola `outputSchema`

---

## Observabilidade (mínimo)

Recomendado logar:
- `correlationId` (header `X-Correlation-Id`)
- `dslProfile` (`ir`)
- `planSource`:
  - `"explicit"` (plan enviado pelo client)
  - `"llm"` (gerado por LLM)
  - `"template:T1|T2|T5"` (fallback)

Métricas:
- contador por `planSource`
- latência total do preview
- latência de execução do Plan
- quantidade de rows produzidas

