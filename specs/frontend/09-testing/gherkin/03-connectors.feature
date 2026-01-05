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
Cenário: Criar conector com API Token (POST /api/v1/connectors)
  Dado que eu estou na tela "Conectores"
  Quando eu clico em "Novo Conector"
  E eu informo o nome "Connector Token"
  E eu informo a baseUrl "https://example.test"
  E eu informo o authRef "authref-token"
  E eu informo o timeoutSeconds "30"
  E eu informo o apiToken "secret-token"
  E eu clico em "Salvar"
  Então eu devo ver o conector "Connector Token" na lista
  E eu devo ver o indicador "Token configurado" para "Connector Token"
  E ao reabrir o editor do conector "Connector Token" o campo apiToken deve estar vazio

Cenário: Editar conector mantendo API Token (PUT /api/v1/connectors/{id})
  Dado que existe um conector "Connector Token" com token configurado
  Quando eu edito o conector "Connector Token"
  E eu altero o timeoutSeconds para "45"
  E eu não informo apiToken
  E eu clico em "Salvar"
  Então o conector "Connector Token" deve continuar com indicador "Token configurado"

Cenário: Remover API Token (PUT /api/v1/connectors/{id})
  Dado que existe um conector "Connector Token" com token configurado
  Quando eu edito o conector "Connector Token"
  E eu clico em "Limpar token"
  E eu clico em "Salvar"
  Então o conector "Connector Token" não deve exibir indicador "Token configurado"

