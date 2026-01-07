# RecordPathDiscovery — Encontrar o array principal em JSON variado

## Objetivo
Dado `sampleInput` (qualquer JSON), encontrar o melhor `recordPath` (JSON Pointer) que aponte para `array<object>`.

## Regras
1. Se root for array e itens forem objetos: `recordPath = "/"` (score 1.0)
2. Caso contrário:
   - percorrer recursivamente e coletar paths onde o valor é array com >=1 item
   - computar score

## Score (0..1)
- `objectRatio` = % de itens do array que são objetos
- `sizeScore` = min(1, log10(len+1)/2) (favorece arrays maiores)
- `nameScore` = 1.0 se o nome do field do path aparecer no goal (case-insensitive), senão 0.5 para nomes comuns (items/results/data/list), senão 0.0
- `depthPenalty` = min(0.3, depth*0.05) (penaliza arrays muito profundos)

Score final:
`score = 0.55*objectRatio + 0.25*sizeScore + 0.25*nameScore - depthPenalty`
Clamp 0..1.

## Seleção
- ordenar por score desc
- se top1.score >= 0.75 e (top1.score - top2.score) >= 0.10: escolher top1
- se ambíguo: retornar lista top3 e marcar warning `AmbiguousRecordPath`
  - em `engine=plan_v1`: LLM escolhe 1 dentre top3 (com explicação curta)
  - em `engine=auto`: escolher top1 e prosseguir, mas incluir warning

## Output
```csharp
public record RecordPathCandidate(string JsonPointer, double Score, int Length, double ObjectRatio, string? Reason);
```

## Observabilidade
Logar:
- top3 candidates (pointer + score + len + objectRatio)
- pointer escolhido
- se houve ambiguidade
