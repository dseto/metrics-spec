# IT13 — PlanV1/IR Assisted Flow Tests (Integration)

Data: 2026-01-07

Esta suite valida o fluxo determinístico **PlanV1/IR** (sem depender de LLM),
cobrindo execução end-to-end do `PlanExecutor` e validação/CSV.

> Importante: testes com LLM real devem ficar isolados em `IT04` (Category=LLM).

---

## Propósito

- Validar `recordPath` discovery (root array, wrappers, nested wrappers)
- Validar steps do plano:
  - select
  - filter
  - groupBy/aggregate
  - mapValue
  - limit/topN

---

## Test cases típicos (exemplos)

- `PlanV1_SimpleExtraction_PortuguesePrompt_RootArray`
- `PlanV1_Aggregation_EnglishPrompt`
- `PlanV1_WeatherForecast_NestedPath`
- `PlanV1_SelectWithFilter`
- `PlanV1_GroupBy_Avg`
- `PlanV1_MapValue`
- `PlanV1_Limit_TopN`

---

## Como rodar

```bash
# apenas IT13
dotnet test Metrics.Simple.SpecDriven.sln --filter "FullyQualifiedName~IT13_LLMAssistedDslFlowTests"

# todos PlanV1 (sem LLM)
dotnet test Metrics.Simple.SpecDriven.sln --filter "Category=PlanV1"
```

---

## Estrutura canônica de um teste

1) Arrange:
- `sampleInput` + `goalText`
2) Act:
- gerar plano (template ou dado hardcoded)
- executar transform/preview com `plan`
3) Assert:
- CSV preview não vazio
- output valida contra `outputSchema`

