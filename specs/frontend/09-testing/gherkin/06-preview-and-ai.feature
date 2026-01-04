# language: pt
@e2e @security @v1_1_3
Funcionalidade: Preview de Transform e Geração de DSL (AI)
  Para acelerar configuração com segurança
  Como usuário autenticado
  Quero gerar e validar DSL usando AI e preview

  Contexto:
    Dado que eu estou autenticado como "ADMIN_USERNAME"

  Cenário: Gerar DSL via AI (POST /api/v1/ai/dsl/generate)
    Dado que eu estou na tela "Editor de DSL"
    Quando eu informo o objetivo "Gerar uma transformação simples"
    E eu informo um sampleInput válido
    E eu clico em "Gerar DSL (AI)"
    Então eu devo ver um texto de DSL gerado

  Cenário: Preview de transformação (POST /api/v1/preview/transform)
    Dado que eu possuo um DSL preenchido
    E eu possuo um sampleInput preenchido
    Quando eu clico em "Preview"
    Então eu devo ver o resultado do preview sem erros

  @security
  Cenário: Preview deve enviar Authorization Bearer
    Dado que eu estou autenticado como "ADMIN_USERNAME"
    Quando eu executo "Preview"
    Então a requisição deve conter o header "Authorization" com prefixo "Bearer "
