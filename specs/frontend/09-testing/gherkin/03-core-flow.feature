# language: pt
@e2e @v1_1_3
Funcionalidade: Fluxos principais (Connectors, Processes, Versions, Preview, AI)
  Como usuário autenticado
  Quero executar os fluxos principais do produto
  Para validar o contrato da UI com a API

  Contexto:
    Dado que eu estou autenticado como "<ADMIN_USERNAME>"

  Cenário: CRUD básico de Conector (API /api/v1/connectors)
    Quando eu acesso a tela "Conectores"
    E eu crio um conector com nome "Connector E2E" e baseUrl "https://example.test" e timeoutSeconds "30"
    Então eu devo ver o conector "Connector E2E" na lista

  Cenário: Criar Processo e Versionar (API /api/v1/processes e /api/v1/processes/{processId}/versions)
    Dado que existe um conector "Connector E2E"
    Quando eu acesso a tela "Processos"
    E eu crio um processo com nome "Processo E2E" usando o conector "Connector E2E"
    E eu crio a versão "1" para o processo "Processo E2E" com enabled verdadeiro
    Então eu devo ver a versão "1" na lista de versões do processo "Processo E2E"

  Cenário: Preview de Transform (API /api/v1/preview/transform)
    Dado que eu estou na tela "Editor de Versão"
    E eu possuo DSL e sampleInput preenchidos
    Quando eu executo "Preview"
    Então eu devo ver o resultado do preview sem erros

  Cenário: Gerar DSL via AI (API /api/v1/ai/dsl/generate)
    Dado que eu estou na tela "AI Assistant"
    Quando eu solicito gerar um DSL a partir de um objetivo e sampleInput
    Então eu devo ver um texto de DSL retornado pela API
