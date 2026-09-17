#!/usr/bin/env bash
set -euo pipefail

APP_DIR=/opt/pwa/cash-flow
HOST_SITE=/etc/nginx/sites-enabled/cash-flow
HOST_AVAILABLE=/etc/nginx/sites-available/cash-flow
ROLLBACK_FILE="$APP_DIR/ops/host-nginx-rollback/cash-flow"

cd "$APP_DIR"
docker compose down

if [[ ! -f "$ROLLBACK_FILE" ]]; then
  echo "Configuração de rollback ausente: $ROLLBACK_FILE" >&2
  exit 1
fi

install -o root -g root -m 644 "$ROLLBACK_FILE" "$HOST_AVAILABLE"
ln -sfn "$HOST_AVAILABLE" "$HOST_SITE"
nginx -t
systemctl reload nginx
curl --fail --silent --show-error http://127.0.0.1:8087/ >/dev/null
