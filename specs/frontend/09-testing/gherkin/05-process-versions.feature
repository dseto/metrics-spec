# language: pt
@e2e @v1_1_3
Funcionalidade: Versões de Processo (ProcessVersions)
  Como usuário autenticado
  Quero criar e editar versões de processo
  Para controlar evolução do pipeline

  Contexto:
    Dado que eu estou autenticado como "ADMIN_USERNAME"
    E existe um processo "Processo E2E"

  Cenário: Criar versão (POST /api/v1/processes/{processId}/versions)
    Quando eu abro o processo "Processo E2E"
    E eu clico em "Nova Versão"
    E eu informo a versão "1"
    E eu marco "enabled" como verdadeiro
    E eu configuro sourceRequest method "GET"
    E eu configuro sourceRequest path "/example"
    E eu informo o DSL profile "default"
    E eu informo o DSL text "SELECT * FROM input"
    E eu clico em "Salvar Versão"
    Então eu devo ver a versão "1" na lista de versões

  Cenário: Atualizar versão (PUT /api/v1/processes/{processId}/versions/{version})
    Dado que existe a versão "1" para o processo "Processo E2E"
    Quando eu abro a versão "1"
    E eu desmarco "enabled"
    E eu clico em "Salvar Versão"
    Então a versão "1" deve estar com enabled igual a falso
