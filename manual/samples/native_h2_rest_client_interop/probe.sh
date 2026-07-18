#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
PORT="${IGNITE_H2_INTEROP_PORT:-18882}"
SERVER_LOG="${IGNITE_H2_INTEROP_SERVER_LOG:-/tmp/ignite-native-h2-rest-client-node.log}"
CLIENT_BIN="${IGNITE_H2_INTEROP_CLIENT_BIN:-/tmp/ignite-native-h2-rest-client-interop}"

cleanup() {
  if [[ -n "${SERVER_PID:-}" ]]; then
    kill "${SERVER_PID}" 2>/dev/null || true
    wait "${SERVER_PID}" 2>/dev/null || true
  fi
}
trap cleanup EXIT INT TERM

IGNITE_H2_INTEROP_PORT="${PORT}" \
  node "${ROOT}/manual/samples/native_h2_rest_client_interop/server.mjs" \
  >"${SERVER_LOG}" 2>&1 &
SERVER_PID=$!

for _ in $(seq 1 80); do
  if grep -q "ready:${PORT}" "${SERVER_LOG}" 2>/dev/null; then
    break
  fi
  sleep 0.05
done

if ! grep -q "ready:${PORT}" "${SERVER_LOG}" 2>/dev/null; then
  echo "[native-h2-rest-client] Node server did not become ready" >&2
  cat "${SERVER_LOG}" >&2
  exit 1
fi

IGNITE_H2_INTEROP_PORT="${PORT}" \
  "${ROOT}/manual/samples/_shared/run_server_sample.sh" \
  "manual/samples/native_h2_rest_client_interop/main.cj" "${CLIENT_BIN}"

echo "[native-h2-rest-client] Node log: ${SERVER_LOG}"
