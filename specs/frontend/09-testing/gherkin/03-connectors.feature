# language: pt
@e2e @v1_1_3
Funcionalidade: Conectores
  Como usuário autenticado
  Quero criar e listar conectores
  Para usar nos processos

  Contexto:
    Dado que eu estou autenticado como "ADMIN_USERNAME"

  @smoke
  Cenário: Listar conectores (GET /api/v1/connectors)
    Quando eu acesso a tela "Conectores"
    Então eu devo ver a lista de conectores

  Cenário: Criar conector (POST /api/v1/connectors)
    Dado que eu estou na tela "Conectores"
    Quando eu clico em "Novo Conector"
    E eu informo o nome "Connector E2E"
    E eu informo a baseUrl "https://example.test"
    E eu informo o authRef "authref-e2e"
    E eu informo o timeoutSeconds "30"
    E eu clico em "Salvar"
    Então eu devo ver o conector "Connector E2E" na lista
