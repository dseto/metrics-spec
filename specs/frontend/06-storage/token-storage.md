# Token Storage

Data: 2026-01-08

## Objetivo
Definir onde e como o token é armazenado no frontend.

## Regras
- Não armazenar senha.
- Preferir `localStorage` para persistir sessão em reload.
- Chave padrão:
  - `metrics.auth.access_token`
- Em logout ou 401:
  - remover token do storage.

## API sugerida (TypeScript)
```ts
interface TokenStorage {
  get(): string | null;
  set(token: string): void;
  clear(): void;
}
```

## Observações
- Se houver exigência futura de maior segurança, migrar para cookies HttpOnly (quando Okta/Entra entrarem).
