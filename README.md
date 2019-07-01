Anti-plágio
===

API anti-plágio de código, feita para a prova inicial da Dextra.

Primeiros passos
---
Esta seção especifica primeiros passos para rodar a API.


### Pré-requisitos

Requer [Ruby](https://www.ruby-lang.org/pt/).

Recomenda-se usar a última versão 2.x disponível, mas teoricamente qualquer
versão acima da 2.2 funciona.


### Instalação

Instale as gems necessárias com `bundle`. Na pasta raíz do repositório:

    $ bundle install


### Testando

Este projeto usa [`rspec`](https://rspec.info/) como framework de testes
automatizados.

Para executar, execute na raíz do repositório:

    $ rspec -fd


### Executando localmente

Para executar a API, é necessário ter uma conexão com um servidor Firebase.
Uma vez providenciado o servidor, crie variáveis de ambiente `FIREBASE_URL` e
`FIREBASE_KEY_FILE` com a URL para o banco de dados do firebase e o arquivo
json com a chave privada de acesso, respectivamente.

Para formas de obter a URL e a chave privada, veja os links:
- [Where can I find my Firebase reference URL in Firebase account?][1]
- [Add the Firebase Admin SDK to Your Server][2]

    [1]: https://stackoverflow.com/questions/40168564/where-can-i-find-my-firebase-reference-url-in-firebase-account
    [2]: https://firebase.google.com/docs/admin/setup#initialize_the_sdk

Feito isso, basta executar:

    $ ruby api.rb


### Endpoints

#### `POST /submit/:user_id/:question_id`

Endpoint de envio de resposta.

##### Parâmetros
- `user_id`: Código do usuário enviando a resposta. Armazenado a fim de
  relacionar com outras bases.
- `question_id`: Código da questão, usado para fazer a comparação com as demais
  respostas armazenadas.

##### Corpo
O corpo da requisição deve conter a resposta dada pelo usuário para a questão,
em texto puro (a rever).

##### Resposta
A resposta é o código da entrada gerada no firebase para a submissão, em texto
puro (a rever).

---

<center><h2>Em construção...</h2></center>