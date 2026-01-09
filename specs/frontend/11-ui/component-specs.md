# Component Specs (Patch) — tipos e contratos impactados por IR/Auth

Data: 2026-01-08

> Este arquivo é um *patch* do `11-ui/component-specs.md` para remover ambiguidade do que mudou com IR/Auth.
> Se o seu deck atual já contém esses tipos, sincronize os trechos abaixo.

## Tipos comuns (DTOs)

### DslDto
```ts
export type DslDto = {
  profile: 'ir';
  text: string; // JSON string do Plan IR
};
```

### Auth state (UI)
```ts
export type AuthState =
  | { kind: 'anonymous' }
  | { kind: 'authenticating' }
  | { kind: 'authenticated', token: string, roles?: string[] }
  | { kind: 'error', message: string };
```

## Componentes
### MsLoginForm
- Props:
  - `loading: boolean`
  - `errorText?: string | null`
- Events:
  - `submit(username: string, password: string)`

### MsRoleGate
Renderiza children somente quando o usuário possui role exigida.
- Props:
  - `requiredRole: 'Metrics.Admin' | 'Metrics.Reader' | string`
  - `roles: string[]`

### MsAiAssistantPanel (IR)
- Não possui `dslProfile` select.
- Deve expor constraints avançadas e enviar `dslProfile='ir'` sempre.
