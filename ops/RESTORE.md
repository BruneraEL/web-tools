# Cash Flow — restauração

O Cash Flow não mantém dados no servidor. A restauração consiste em recuperar o código-fonte no
Git, reconstruir ou carregar a imagem preservada e restaurar o Compose e as configurações Nginx.

1. Recuperar a release Git correspondente.
2. Carregar a imagem preservada ou reconstruí-la no HST2.
3. Restaurar `compose.yaml`, `nginx/default.conf` e `ops/` em `/opt/pwa/cash-flow`.
4. Confirmar que a porta `127.0.0.1:8087` está livre.
5. Executar `docker compose up -d --no-build`.
6. Confirmar o estado `healthy`, `/healthz`, `/cash-flow/` e a URL HTTPS privada.
7. Revalidar manifest, service worker e funcionamento offline no iPhone.

Para retornar temporariamente ao Nginx do host, use `ops/rollback-to-host-nginx.sh` enquanto a
cópia preservada em `ops/host-nginx-rollback/cash-flow` existir.
