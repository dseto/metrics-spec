# LLM Provider Abstraction

Data: 2026-01-07

Este documento elimina “tribal knowledge” sobre como o backend integra com LLMs.
O objetivo é ter uma arquitetura **plugável** (Okta/Entra no front é independente; aqui é LLM provider),
com **uma única interface** e um contrato claro de configuração, erros e testes.

---

## 1) Visão Geral

### Quando o LLM é usado?
Somente em **design-time**, para gerar `plan` a partir de:
- `goalText`
- `sampleInput`
- `constraints` / `hints`

Endpoint: `POST /api/v1/ai/dsl/generate`  
Doc: `specs/backend/08-ai-assist/ai-endpoints.md`

### Quando o LLM NÃO é usado?
Em **runtime transform**, o backend executa o `plan` determinístico (PlanExecutor) e não chama LLM.

---

## 2) Interface `IAiProvider`

O backend deve depender de uma interface e não do provider concreto:

```csharp
public interface IAiProvider
{
    Task<DslGenerateResult> GenerateDslAsync(DslGenerateRequest request, CancellationToken ct);
    string ProviderName { get; }
}
```

- `DslGenerateRequest` e `DslGenerateResult` seguem os schemas em `specs/shared/domain/schemas/`.

---

## 3) Implementações

### 3.1 HttpOpenAiCompatibleProvider (OpenRouter) — ÚNICO EM USO

- Endpoint padrão:
  - `https://openrouter.ai/api/v1/chat/completions`
- Autenticação:
  - header `Authorization: Bearer <OpenRouterApiKey>`
  - a key vem de `METRICS_OPENROUTER_API_KEY`
- Modelo (exemplo usado em testes):
  - `deepseek/deepseek-chat-v3.1`

Responsabilidades típicas:
- montar prompt/system + user
- fazer chamada HTTP
- aplicar "structured output" quando disponível
- validar JSON gerado
- "response healing" (tentar corrigir JSON quebrado)
- retornar `DslGenerateResult` válido, com:
  - `dsl.profile == "ir"`
  - `plan` válido

### 3.2 MockProvider (futuro)

Objetivo:
- testes determinísticos sem custo externo
- simular cenários: timeout, rate-limit, JSON inválido

Deve ser habilitado somente por config (ex.: `Ai:Provider=Mock`).

---

## 4) Configuração (`AiConfiguration`)

Config deve vir de:
1. variáveis de ambiente
2. appsettings
3. defaults

Tabela de campos recomendados:

| Campo | Tipo | Padrão | Env Var | Obrigatório |
|------|------|--------|---------|------------|
| Enabled | bool | false | - | Não |
| Provider | string | `HttpOpenAICompatible` | - | Sim |
| EndpointUrl | string | `https://openrouter.ai/api/v1/chat/completions` | - | Sim |
| Model | string | `deepseek/deepseek-chat-v3.1` | - | Sim |
| ApiKey | string? | null | `METRICS_OPENROUTER_API_KEY` | Se Enabled=true |
| TimeoutSeconds | int | 30 | - | Não |
| MaxRetries | int | 1 | - | Não |
| Temperature | double | 0.0 | - | Não |
| MaxTokens | int | 4096 | - | Não |
| EnableStructuredOutputs | bool | true | - | Não |
| EnableResponseHealing | bool | true | - | Não |

Regras:
- se `Enabled=false` → endpoint `/api/v1/ai/dsl/generate` deve retornar erro controlado (ex.: 503 com code `AI_DISABLED`)
- se `Enabled=true` mas `ApiKey` ausente → erro controlado (ex.: `AI_DISABLED` ou `AI_MISCONFIGURED`)

---

## 5) Error Handling (contrato)

Padronizar exceções e códigos:

- `AI_DISABLED` — AI desabilitada/config incompleta
- `AI_TIMEOUT` — timeout do provider
- `AI_RATE_LIMITED` — HTTP 429 / rate limit
- `AI_OUTPUT_INVALID` — JSON inválido / schema inválido
- `AI_PROVIDER_ERROR` — 5xx / erro inesperado

### Retry Strategy (exponential backoff)

Quando `AI_RATE_LIMITED` ou erros transitórios:
- `MaxRetries` tentativas
- backoff exponencial (ex.: 250ms, 500ms, 1s...)
- jitter (opcional)

Não fazer retry em:
- 4xx de validação do request do cliente
- output inválido persistente (a não ser que use "response healing" primeiro)

---

## 6) Dependency Injection (DI)

O provider HTTP depende de `IHttpClientFactory`.
Portanto, **é obrigatório** registrar o HttpClient:

```csharp
builder.Services.AddHttpClient("AI");
```

E então registrar o engine/provider de modo que o factory consiga resolver:

```csharp
builder.Services.AddScoped<IAiProvider>(sp =>
{
    var cfg = sp.GetRequiredService<AiConfiguration>();
    if (!cfg.Enabled) return new DisabledAiProvider();

    var apiKey = Environment.GetEnvironmentVariable("METRICS_OPENROUTER_API_KEY");
    if (string.IsNullOrWhiteSpace(apiKey)) return new DisabledAiProvider();

    var http = sp.GetRequiredService<IHttpClientFactory>().CreateClient("AI");
    return new HttpOpenAiCompatibleProvider(http, cfg, sp.GetRequiredService<ILogger<HttpOpenAiCompatibleProvider>>());
});
```

Doc detalhado de DI: `specs/backend/04-execution/02-dependency-injection.md`

---

## 7) Como testar

### Offline (sem chave)
- rode suites `Validation` e `PlanV1` (sem `Category=LLM`)
- o endpoint AI pode estar desabilitado

### Online (com OpenRouter)
- configure `METRICS_OPENROUTER_API_KEY`
- rode `dotnet test --filter "Category=LLM"`

Doc: `specs/backend/08-ai-assist/ai-tests.md`

---

## 8) Como adicionar um novo provider (Okta/Entra não se aplica aqui)

1. Implementar `IAiProvider`
2. Adicionar nome/config no `AiConfiguration`
3. Registrar no DI de forma condicional (`Provider == ...`)
4. Adicionar testes:
   - unit tests do provider (mock HTTP)
   - 1-2 integration tests isolados por trait

