# Cash Flow

PWA estática que classifica os cartões pelo prazo estimado entre a compra atual e o pagamento.
Toda a lógica é executada no navegador; não há backend, banco de dados ou dados persistentes no
servidor.

## Produção

- URL privada: `https://bddha-lab01.tail97ab45.ts.net/cash-flow/`
- Container: `cash-flow`
- Imagem: `cash-flow:1.0.0`
- Porta: `127.0.0.1:8087` para `8080` no container
- Gateway: Nginx do host em `/cash-flow/`
- Cache offline: `cash-flow-lab01-v3`

## Operação

O build é feito no HST2 e a imagem pronta é transferida ao LAB01. O LAB01 não baixa dependências
nem constrói a imagem. Os procedimentos de publicação, rollback e restauração ficam em `ops/`.

O app não precisa de backup periódico de dados nem de pacote no DR central. O código e o histórico
ficam no Git, a imagem é reproduzível e o rollback operacional para o Nginx do host permanece
documentado em `ops/`.
