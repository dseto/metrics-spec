# Engine Service (Transform & Validation)

Data: 2026-01-07

## Contexto

O backend possui um engine responsável por:
- executar transformações (dependendo do profile),
- validar saída contra JSON Schema,
- gerar CSV com base nas rows finais.

Historicamente, o engine executava transformações a partir de DSL (ex.: `jsonata`).
Com `plan_v1`, parte da execução passa a ocorrer no `PlanExecutor`, e o engine precisa
suportar o cenário “rows já executadas”.

---

## TransformValidateToCsvFromRows

### Assinatura (C#)
```csharp
public EngineTransformResult TransformValidateToCsvFromRows(
    JsonElement rowsArray,
    JsonElement outputSchema)
```

### Propósito
- Validar `rowsArray` (array de objetos) contra `outputSchema`
- Gerar CSV a partir das `rows` já prontas
- Retornar um `EngineTransformResult` com:
  - `IsValid` + lista de erros (quando inválido)
  - `Csv` (quando válido)
  - (opcional) `Rows` normalizadas, dependendo da implementação

### Entradas
- `rowsArray`: JSON array de objetos (output do PlanExecutor)
- `outputSchema`: JSON Schema de validação do output

### Saídas
- `EngineTransformResult` com validação e CSV.

### Onde é usado
- `POST /api/v1/preview/transform` quando `dsl.profile == "plan_v1"` e `plan != null`
  - Handler: `src/Api/Program.cs`
  - Execução do plano: `PlanExecutor`
  - Validação/CSV: `TransformValidateToCsvFromRows`

---

## Diferença para “transform a partir de DSL”

| Modo | Execução | Quando usar |
|---|---|---|
| DSL-based (legacy) | Engine executa DSL (ex.: jsonata) | perfis legacy |
| Rows-based (`plan_v1`) | PlanExecutor executa steps → engine valida/gera CSV | `plan_v1` |

---

## Erros e contratos

- Se `rowsArray` não for array → erro de request (400)
- Se `rowsArray` for array mas violar `outputSchema` → retorno `200 OK` com `isValid=false` no preview

Detalhes do contrato de preview: `specs/shared/domain/schemas/previewResult.schema.json`
