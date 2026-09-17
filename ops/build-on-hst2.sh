#!/usr/bin/env bash
set -euo pipefail

SOURCE_DIR="${1:-/tmp/cash-flow-release}"
OUTPUT="${2:-/tmp/cash-flow-1.0.0-image.tar.gz}"
TEST_CONTAINER=cash-flow-build-test

cleanup() {
  docker rm -f "$TEST_CONTAINER" >/dev/null 2>&1 || true
}
trap cleanup EXIT

docker build --pull -t cash-flow:1.0.0 "$SOURCE_DIR"
docker tag cash-flow:1.0.0 cash-flow:0.9.0

docker run -d --name "$TEST_CONTAINER" \
  --user 101:101 \
  --read-only \
  --tmpfs /tmp:rw,noexec,nosuid,size=16m \
  --security-opt no-new-privileges \
  --cap-drop ALL \
  -p 127.0.0.1:18087:8080 \
  cash-flow:1.0.0 >/dev/null

for _ in $(seq 1 20); do
  if [[ "$(docker inspect --format '{{.State.Health.Status}}' "$TEST_CONTAINER")" == "healthy" ]]; then
    break
  fi
  sleep 1
done

[[ "$(docker inspect --format '{{.State.Health.Status}}' "$TEST_CONTAINER")" == "healthy" ]]
curl --fail --silent --show-error http://127.0.0.1:18087/healthz >/dev/null
curl --fail --silent --show-error http://127.0.0.1:18087/ >/dev/null
curl --fail --silent --show-error http://127.0.0.1:18087/manifest.json >/dev/null
curl --fail --silent --show-error http://127.0.0.1:18087/service-worker.js >/dev/null

docker save cash-flow:1.0.0 | gzip -1 > "$OUTPUT"
chmod 644 "$OUTPUT"

docker image inspect --format 'image={{.RepoTags}} id={{.Id}} architecture={{.Architecture}}' cash-flow:1.0.0
sha256sum "$OUTPUT"
echo "Imagem validada e salva em $OUTPUT"
