# language: pt
@e2e @v1_1_3
Funcionalidade: Processos
  Como usuário autenticado
  Quero criar, editar e excluir processos
  Para configurar pipelines no Metrics Simple

  Contexto:
    Dado que eu estou autenticado como "ADMIN_USERNAME"

  @smoke
  Cenário: Listar processos (GET /api/v1/processes)
    Quando eu acesso a tela "Processos"
    Então eu devo ver a lista de processos

  Cenário: Criar processo (POST /api/v1/processes)
    Dado que eu estou na tela "Processos"
    Quando eu clico em "Novo Processo"
    E eu informo o nome "Processo E2E"
    E eu seleciono o conector "Connector E2E"
    E eu defino o status como "Active"
    E eu adiciono um destino de saída do tipo "local"
    E eu informo o basePath "/tmp/metrics"
    E eu clico em "Salvar"
    Então eu devo ver o processo "Processo E2E" na lista

  Cenário: Excluir processo (DELETE /api/v1/processes/{id})
    Dado que existe um processo "Processo E2E"
    Quando eu excluo o processo "Processo E2E"
    Então o processo "Processo E2E" não deve mais aparecer na lista
