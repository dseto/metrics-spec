# Shape Normalization — garantir array<object> para validação e CSV

## Objetivo
Evitar falhas do tipo:
- "Array items must be objects"
- preview retornando objeto com `items`
- preview retornando `undefined`/null

## Regras
1. Se output for `array`:
   - se todos itens são object: OK
   - se itens são scalars: encapsular em `{ "value": <scalar> }` (warning ScalarArrayWrapped)
2. Se output for `object`:
   - se existir exatamente 1 propriedade cujo valor é `array<object>`: usar essa array (warning ObjectWrappedArray)
   - caso contrário: encapsular o objeto em `[obj]` (warning ObjectWrappedSingle)
3. Se output for `null`/missing/undefined (string literal):
   - erro `PreviewUndefined` (não tentar parsear como JSON)
   - em `engine=auto`, fallback para legacy
   - em `engine=plan_v1`, retornar 400 NeedClarification com mensagem orientativa

## CSV
Somente gerar CSV quando tiver `array<object>` após normalização.
