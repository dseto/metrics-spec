# AI Provider Contract (Design-time DSL Generation)

Data: 2026-01-07

Este documento define **contratos e invariantes** para geração assistida por LLM (design-time),
incluindo: perfis suportados, comportamento de `plan`, compatibilidade e requisitos de autenticação.

> Fonte da verdade dos modelos: `specs/shared/domain/schemas/*.schema.json`

---

## Conceitos

### 1) `dslProfile` (requests)
Campo usado em `DslGenerateRequest` para indicar o **profile alvo** que o backend deve gerar.

- **Atualmente suportado:** `ir`
- **Rejeitado:** qualquer outro valor (ex.: `jsonata`, `jmespath`)

Schema: `specs/shared/domain/schemas/dslGenerateRequest.schema.json`

### 2) `DslDto.profile` (responses / persistência)
Campo no objeto `dsl` retornado em `DslGenerateResult` e persistido em versões/processos.

- **Valor atual esperado:** `ir`

Schema: `specs/shared/domain/schemas/dslGenerateResult.schema.json`

---

## Supported DSL Profiles

### Profile: `ir` — CURRENT / ONLY
- Objetivo: **Intermediate Representation** para execução determinística via **PlanV1**.
- Engine: `plan_v1`
- Execução: server-side por `PlanExecutor` (preview/transform)
- LLM-capable: sim (OpenRouter, endpoint OpenAI-compatible)
- Required: `plan` (objeto conforme `planV1.schema.json`)

### Profile: `jsonata` — REMOVED (legacy)
- Status: removido do backend em **2026-01-07**
- Uso permitido: apenas como **referência histórica** em docs e migração
- Requests com `jsonata` devem ser rejeitados (400 / validation)

---

## Invariante principal: `plan` é o formato executável

Para `ir`, o **formato executável** é o objeto `plan` retornado pelo backend e/ou enviado pelo client,
conforme schema:

- `specs/shared/domain/schemas/planV1.schema.json`

O campo `dsl.text` pode existir para:
- logging/auditoria (registro do plano como JSON-string),
- persistência da versão,
- debug (UI/DevTools).

Mas **a execução deve usar `plan`**.

---

## Auth & Auditability (Design-time)

Geração de DSL/Plan é uma operação com risco (custo LLM, possível acesso a dados de exemplo, auditabilidade).
Por isso, endpoints de AI devem sempre exigir usuário autenticado e permitir rastrear:

- quem chamou (subject/userId),
- quando,
- qual endpoint,
- quais parâmetros principais (ex.: `dslProfile`, tamanho do `goalText`, `model`).

Detalhes do endpoint: `specs/backend/08-ai-assist/ai-endpoints.md`

---

## Exemplos canônicos

- `specs/shared/examples/dslGenerateResult.sample.json`
- `specs/shared/examples/previewRequest.sample.json`

