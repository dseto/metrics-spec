# UI API Client Contract — DTOs, Endpoints, Normalização, Auth

Data: 2026-01-08

## Base URL
- Endpoints versionados: `/api/v1`
- Auth endpoint: `/api/auth/token`
- Health: `/health`

## Headers
- Sempre: `Content-Type: application/json`
- Opcional: `X-Correlation-Id` (UUID por request, para troubleshooting)
- Para `/api/v1/*`: `Authorization: Bearer <access_token>` (via interceptor)

---

## DTOs essenciais (TypeScript)

### DslDto
```ts
export type DslDto = {
  profile: 'ir';
  /** JSON string de Plan IR (ou outra IR do futuro). */
  text: string;
};
```

### DslGenerateRequest
Espelhar `specs/shared/domain/schemas/dslGenerateRequest.schema.json`.

```ts
export type DslGenerateConstraints = {
  maxColumns: number;           // default 50
  allowTransforms: boolean;     // default true
  forbidNetworkCalls: boolean;  // default true
  forbidCodeExecution: boolean; // default true
};

export type DslGenerateRequest = {
  goalText: string;
  sampleInput: unknown;         // objeto (JSON.parse do textarea)
  dslProfile: 'ir';
  constraints: DslGenerateConstraints;

  // opcionais:
  hints?: { columns?: string };
  existingDsl?: DslDto | null;
  existingOutputSchema?: unknown | null;
  engine?: 'plan_v1';           // opcional (pode omitir)
};
```

### DslGenerateResult
Espelhar `specs/shared/domain/schemas/dslGenerateResult.schema.json`.

```ts
export type DslGenerateResult = {
  dsl: DslDto;
  outputSchema: unknown;
  exampleRows?: unknown[];
  plan?: unknown | null;        // Plan IR (objeto)
  rationale: string;
  warnings: string[];
  modelInfo?: unknown;
};
```

### PreviewTransformRequest
Espelhar `specs/shared/domain/schemas/previewRequest.schema.json`.

```ts
export type PreviewTransformRequest = {
  sampleInput: unknown;
  dsl: DslDto;
  outputSchema: unknown;
  plan?: unknown | null; // enviar quando disponível (preferido)
};
```

### PreviewTransformResponse
(Manter conforme backend atual. Se houver schema no shared, preferir o schema.)
```ts
export type ValidationErrorItem = { path: string; message: string; kind?: string | null };
export type PreviewTransformResponse = {
  isValid: boolean;
  errors: ValidationErrorItem[];
  output: unknown | null;
  previewCsv?: string | null;
};
```

---

## Endpoints (frontend)

### AI: gerar DSL/Schema
- `POST /api/v1/ai/dsl/generate`
- Auth: **Bearer obrigatório**

### Preview/Transform
- `POST /api/v1/preview/transform`
- Auth: seguir padrão do backend (recomendação: proteger tudo sob `/api/v1/*`)

### CRUD (exemplos; verificar OpenAPI)
- `/api/v1/processes`
- `/api/v1/processes/{processId}/versions`
- `/api/v1/connectors`

---

## Normalização
- `trim()` em strings de campos editáveis: id, name, connectorId, baseUrl, authRef, path
- Bloquear Save se obrigatório ficar vazio após trim.
- `sampleInputText` (textarea):
  - parse obrigatório (erro “JSON inválido”)
  - nunca chamar API com JSON inválido

---

## Tratamento de erros (client)
- 400 validação: mapear para erros por campo quando possível
- 401: logout automático + redirect `/login`
- 403: snackbar “Sem permissão…”
- 429: snackbar “Muitas requisições; tente novamente.”
- 5xx: ErrorBanner + Retry (quando aplicável)
