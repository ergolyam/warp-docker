#!/bin/sh
set -eu

: "${WARP_PROXY_PORT:=40000}"
: "${LISTEN_HOST:=0.0.0.0}"
: "${LISTEN_PORT:=3080}"

supervisord -c /etc/supervisor/supervisord.conf

echo "Waiting for warp-svc..."
i=0
until warp-cli --accept-tos status >/dev/null 2>&1; do
  i=$((i + 1))
  if [ "$i" -ge 30 ]; then
    echo "warp-svc is not ready" >&2
    exit 1
  fi
  sleep 1
done

if ! warp-cli --accept-tos registration show >/dev/null 2>&1; then
  echo "No WARP registration found, registering..."
  warp-cli --accept-tos registration new
else
  echo "Existing WARP registration found"
fi

warp-cli --accept-tos tunnel protocol set MASQUE
warp-cli --accept-tos mode proxy
warp-cli --accept-tos proxy port "${WARP_PROXY_PORT}"
warp-cli --accept-tos connect

echo "Exposing WARP proxy on ${LISTEN_HOST}:${LISTEN_PORT} -> 127.0.0.1:${WARP_PROXY_PORT}"

exec socat \
  "TCP-LISTEN:${LISTEN_PORT},fork,reuseaddr,bind=${LISTEN_HOST}" \
  "TCP:127.0.0.1:${WARP_PROXY_PORT}"
