# MIGRATION_JSONATA_TO_IR (PlanV1)

Data: 2026-01-07

Este guia explica como migrar do formato **legacy JSONata** para o formato atual **IR (PlanV1)**.

> Observação: o nome deste arquivo foi mantido por compatibilidade com versões anteriores do spec deck,
> mas o destino final é **IR** (`dslProfile="ir"`).

---

## Contexto

Antes:
- `dsl.profile = "jsonata"`
- `dsl.text` continha uma expressão JSONata
- preview/transform executavam a DSL diretamente

Agora:
- `dsl.profile = "ir"`
- `plan` é o formato executável (PlanV1)
- preview/transform executam o plano determinístico via `PlanExecutor`
- JSONata foi removido do backend em **2026-01-07**

---

## O que muda no client (UI / API consumer)

### 1) Generate (design-time)
ANTES:
- request: `dslProfile="jsonata"` ou `engine="legacy"`

DEPOIS:
- request: `dslProfile="ir"` e (opcional) `engine="plan_v1"`
- response: inclui `plan` (obrigatório)

### 2) Preview/Transform
ANTES:
- enviar `dsl` (jsonata) + `outputSchema`
- backend executava jsonata

DEPOIS:
- enviar `plan` + `outputSchema` + `sampleInput`
- `dsl` pode existir para display/auditoria, mas não é executado

Schema: `specs/shared/domain/schemas/previewRequest.schema.json`

---

## Migração de dados persistidos (ProcessVersion)

Se existirem versões antigas com `dsl.profile="jsonata"`:

### Estratégia recomendada
1. Marcar versões antigas como **legacy** (read-only)
2. Criar nova versão convertida para IR:
   - gerar `plan` usando templates (T1/T2/T5) quando possível
   - ou re-gerar via AI (`/api/v1/ai/dsl/generate`) com `dslProfile="ir"`

### Por que não converter automaticamente 1:1?
JSONata é expressivo demais e pode não ter mapeamento determinístico direto para PlanV1.

---

## Checklist

- [ ] Atualizar enums/schemas para `dslProfile="ir"` (specs/shared)
- [ ] Atualizar UI/clients para enviar/consumir `plan`
- [ ] Atualizar testes (IT13 determinístico, IT04 LLM real)
- [ ] Confirmar que requests com `jsonata` são rejeitados (400)

