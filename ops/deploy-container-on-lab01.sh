#!/usr/bin/env bash
set -euo pipefail

APP_DIR=/opt/pwa/cash-flow
HOST_SITE=/etc/nginx/sites-enabled/cash-flow
HOST_AVAILABLE=/etc/nginx/sites-available/cash-flow
ROLLBACK_DIR="$APP_DIR/ops/host-nginx-rollback"

mkdir -p "$ROLLBACK_DIR"
if [[ -e "$HOST_AVAILABLE" ]]; then
  cp -a "$HOST_AVAILABLE" "$ROLLBACK_DIR/cash-flow"
fi

rm -f "$HOST_SITE"
nginx -t
systemctl reload nginx

cd "$APP_DIR"
docker compose up -d --no-build

for _ in $(seq 1 20); do
  if [[ "$(docker inspect --format '{{.State.Health.Status}}' cash-flow 2>/dev/null || true)" == "healthy" ]]; then
    curl --fail --silent --show-error http://127.0.0.1:8087/healthz >/dev/null
    exit 0
  fi
  sleep 1
done

echo "Container não ficou saudável; executando rollback." >&2
docker compose down || true
if [[ -f "$ROLLBACK_DIR/cash-flow" ]]; then
  install -o root -g root -m 644 "$ROLLBACK_DIR/cash-flow" "$HOST_AVAILABLE"
  ln -sfn "$HOST_AVAILABLE" "$HOST_SITE"
  nginx -t
  systemctl reload nginx
fi
exit 1
