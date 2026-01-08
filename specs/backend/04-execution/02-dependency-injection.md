# Dependency Injection & Service Registration

Data: 2026-01-07

Este documento descreve o setup de DI do backend (Program.cs) e os registros obrigatórios
para que a aplicação rode localmente e os testes passem.

Motivação: houve um bug crítico onde `IHttpClientFactory` não estava registrado,
causando falha em testes de integração e runtime do provider de AI.

---

## 1) Princípios

- **Tudo que é resolvido pelo container deve estar registrado antes de ser usado.**
- A ordem importa quando:
  - um serviço `A` é construído usando `GetRequiredService<B>()`
  - `B` não foi registrado ainda

---

## 2) Registro obrigatório: HttpClientFactory (AI)

Para o provider de AI (OpenRouter) é obrigatório:

```csharp
builder.Services.AddHttpClient("AI");
```

- Registra `IHttpClientFactory`
- Permite `CreateClient("AI")`

> Sem isso, ocorre:
> `InvalidOperationException: No service for type 'IHttpClientFactory' has been registered.`

---

## 3) Lifetimes (padrão recomendado)

### Singleton
- Configurações carregadas (`AiConfiguration`, options, etc.)
- Cache estático e serviços thread-safe

### Scoped (por request)
- Repositories (SQLite)
- EngineService / PlanExecutor / AiEngine
- Serviços que carregam contexto de usuário/correlation

### Transient
- Helpers puros e stateless (quando aplicável)

---

## 4) Exemplo de “ordem mínima” (Program.cs)

> Este bloco é conceitual: use como checklist.

```csharp
// 1) Configuration & options
builder.Services.AddOptions();
builder.Services.AddSingleton(aiConfig);

// 2) HTTP clients (antes de qualquer provider que use IHttpClientFactory)
builder.Services.AddHttpClient("AI");

// 3) Auth services
builder.Services.AddAuthServices(authOptions);
builder.Services.AddAuthRateLimiting(authOptions);

// 4) Repositories (SQLite)
builder.Services.AddScoped<IProcessRepository>(...);
builder.Services.AddScoped<IProcessVersionRepository>(...);
// ...

// 5) Engine / Transform
builder.Services.AddScoped<PlanExecutor>();
builder.Services.AddScoped<EngineService>();

// 6) AI Engine (pode ser condicional)
builder.Services.AddScoped<AiEngine>();
builder.Services.AddScoped<IAiProvider, HttpOpenAiCompatibleProvider>();
```

---

## 5) Checklist para adicionar um novo serviço

1. Definir lifecycle:
   - Singleton / Scoped / Transient
2. Registrar antes de ser resolvido por outro serviço
3. Escrever ao menos um teste de integração/DI:
   - `dotnet test` deve cobrir “service resolution”
4. Se depender de env vars/secrets:
   - documentar em `specs/backend/04-execution/03-environment-configuration.md`

