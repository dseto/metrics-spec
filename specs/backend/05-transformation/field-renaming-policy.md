# Política de Renomeação de Campos (Delta Spec)

## Problema observado

Modelos tendem a “traduzir” nomes de campos sem o usuário pedir (ex.: `date` → `data`),
o que causa inconsistência e quebra testes/contratos.

## Regra (padrão): ExplicitOnly

**Somente renomear um campo se o usuário pedir explicitamente**, usando termos como:
- “renomear para…”
- “rename to…”
- “chamar de…”
- “output columns: …”
- “colunas: …”

Caso contrário:
- Manter nomes originais do input para campos não mencionados em rename.

## Exemplos

### OK (renomeação explícita)
Prompt: “temperature (rename to 'Temperatura °C')”
→ Campo `temp` pode virar `"Temperatura °C": temp`

### NÃO OK (tradução implícita)
Prompt: “Extract weather forecast: date, temperature...”
→ `date` deve continuar `"date": date` (não `"data"`)

## Impacto em templates
- Templates devem seguir a mesma policy.
- LLM prompt deve reforçar: “Do not translate field names unless explicitly instructed.”

## Critérios de aceite
- Testes IT13 para Weather não falham por tradução automática de `date`.
