# DSL Generation Reliability (Jsonata) — Delta Spec

## 1. Objetivo

Garantir que a funcionalidade de “gerar DSL Jsonata via LLM” seja:

- **Confiável**: resposta sempre parseável (JSON) e DSL executável/validável
- **Consistente**: evita alucinações comuns, reduz variação e regressões
- **Rápida**: retry não pode multiplicar latência sem ganho
- **Auditável**: logs suficientes para identificar modelo/provider/erro

## 2. Escopo

Inclui:
- Chamada ao OpenRouter (Chat Completions)
- Enforcement de formato (structured outputs) e reparo de JSON (response healing)
- Pipeline de geração/validação/repair/fallback
- Inferência determinística de `outputSchema`
- Política de renomeação de campos
- Atualização de testes IT13 alinhada à policy

Fora de escopo:
- Treinar modelo, fine-tuning
- UI/Front-end

## 3. Proposta: Novo Pipeline

### 3.1 Fluxo principal

1. **Classificação rápida do pedido** (regex/keywords)  
   → se “caso comum”, usar Template Library (sem LLM)

2. **Chamada LLM (OpenRouter)** retornando apenas:
```json
{
  "dsl": { "text": "..." },
  "notes": "optional"
}
```

3. **Parse + validação do contrato**  
   - `dsl.text` é obrigatório e não vazio

4. **Validação/eval Jsonata**
   - Executar DSL no `sampleInput` (preview)
   - Se falhar, coletar erro (parser/eval)

5. **Repair loop (máx N tentativas)**
   - Enviar hint específico + DSL anterior + erro
   - Se repetir o mesmo erro → trocar estratégia (template fallback)

6. **Inferir outputSchema via preview**
   - Gerar JSON Schema do output real

7. Retornar:
```json
{
  "dsl": { "text": "..." },
  "outputSchema": { ...inferido... },
  "preview": { ... } // se já existir no contrato atual
}
```

### 3.2 Por que remover `outputSchema` da LLM?

Porque falhas no schema bloqueiam o fluxo **antes** de validar DSL.
O backend já precisa executar preview, então consegue inferir schema com 100% determinismo.

## 4. Contratos / Interfaces

### 4.1 Entrada (já existente)

- `prompt` (texto do usuário)
- `sampleInput` (json)
- opcional: `maxAttempts`, `language`, etc.

### 4.2 Saída (mantida para cliente)

- `dsl.text`
- `outputSchema` (agora gerado no servidor)
- `preview` (se aplicável)

## 5. Critérios de aceite

- Resposta da LLM é sempre parseável (JSON) **ou** falha com erro claro e recuperável (entra no retry).
- `IT13` passa com taxa >= 75% após templates + few-shot.
- Latência: N tentativas *não* pode exceder 10s na média (templates/fallback devem evitar 3 retries inúteis).
- Logs incluem: modelo, provider, request-id do OpenRouter, tentativa, tipo de erro.

## 6. Telemetria / Logs

Por tentativa:
- attemptNumber
- model
- provider (quando disponível)
- responseHealingEnabled
- parseSuccess (bool)
- jsonataEvalSuccess (bool)
- errorCategory: ParseJson | SchemaContract | JsonataSyntax | JsonataEval | Timeout
- errorMessage (truncado)

## 7. Rollout

- Feature flag: `EnableTemplateFallback` ON
- `MaxAttempts`: começar com 2
- Comparar sucesso/latência antes/depois em ambiente de teste
