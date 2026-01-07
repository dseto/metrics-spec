# Plan Engine v1 — Execução determinística de transformação

## Visão geral
O PlanEngine recebe:
- `goal` (texto do usuário)
- `sampleInput` (JSON de exemplo)
- (opcional) `engine=plan_v1`

E produz:
- um **plano IR v1** (JSON)
- preview do resultado
- output schema inferido (permissivo)

## Componentes
### 1) PlanGenerator (LLM → IR)
- Prompt curto, com 3 few-shots.
- Strict JSON Schema: `templates/plan-schema-v1.json`
- Regras:
  - Deve escolher `recordPath`
  - Deve usar JSON pointers relativos ao row para campos
  - Deve usar renamePolicy `ExplicitOnly` por default
  - Deve preferir `mapValue` para traduções e `compute` para cálculos simples

### 2) RecordPathDiscovery (determinístico)
- Antes de chamar LLM, gerar candidatos de recordPath e passar para a LLM como contexto.
- Ver `record-path-discovery.md`.

### 3) FieldResolver (determinístico)
- Resolve pointers e suporta aliases pt/en e busca por chaves.
- Ver `field-resolver-and-aliases.md`.

### 4) PlanExecutor (determinístico)
- Executa steps sequencialmente sobre `rows: List<RowObject>`.
- Suporta ops v1 conforme `templates/plan-ops-reference.md`.

### 5) ShapeNormalizer (determinístico)
- Garante `array<object>` como saída.
- Ver `shape-normalization.md`.

### 6) OutputSchemaInferer (permissivo)
- Inferir schema do preview JSON.
- Ver `output-schema-inference-permissive.md`.

## Contratos internos (interfaces)
### Engine selector
```csharp
public interface IDslGenerationEngine
{
    string Name { get; } // "legacy" or "plan_v1"
    Task<GenerateDslResult> GenerateAsync(GenerateDslRequest request, CancellationToken ct);
}
```

### Plan engine
```csharp
public interface IPlanEngine
{
    Task<PlanGenerationResult> GeneratePlanAsync(string goal, JsonElement sampleInput, CancellationToken ct);
    PlanExecutionResult ExecutePlan(JsonElement sampleInput, TransformPlanV1 plan);
}
```

## Estratégia de fallback
- `engine=plan_v1`: sem fallback automático para legacy (para não mascarar bugs); apenas mensagens claras.
- `engine=auto`: se plan falhar e caso for coberto, tenta legacy como fallback.

## Segurança
- O IR é JSON validado por schema.
- `compute.expr` não pode executar funções arbitrárias.
- Implementar avaliador seguro e limitado (sem reflection, sem eval).

## DoD técnico
- IT13 passa com `engine=plan_v1` >= 3/4
- Casos simples (extract/sort/group) não fazem 2ª chamada LLM
- Nenhum 502 causado por LLM em casos cobertos (template/plan determinísticos)
