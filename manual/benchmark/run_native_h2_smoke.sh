#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SERVER_LOG="${IGNITE_BENCH_SERVER_LOG:-/tmp/ignite0800-native-h2-server.log}"
SERVER_BIN="${IGNITE_BENCH_SERVER_BIN:-/tmp/ignite0800_native_h2_server}"
CLIENT_BIN="${IGNITE_BENCH_H2_CLIENT_BIN:-/tmp/ignite0800_native_h2_smoke}"
OUTPUT="${IGNITE_BENCH_OUTPUT:-/tmp/ignite0800-native-h2-smoke.jsonl}"

cleanup() {
  if [[ -n "${SERVER_PID:-}" ]]; then
    kill "${SERVER_PID}" 2>/dev/null || true
    wait "${SERVER_PID}" 2>/dev/null || true
  fi
}
trap cleanup EXIT INT TERM

IGNITE_BENCH_BACKEND=native-h2 \
  "${ROOT}/manual/samples/_shared/run_server_sample.sh" \
  "manual/benchmark/main.cj" "${SERVER_BIN}" >"${SERVER_LOG}" 2>&1 &
SERVER_PID=$!

IGNITE_SAMPLE_SKIP_BUILD=1 \
  "${ROOT}/manual/samples/_shared/run_server_sample.sh" \
  "manual/benchmark/h2_smoke.cj" "${CLIENT_BIN}" | tee "${OUTPUT}"

echo "[benchmark] Native H2 smoke result: ${OUTPUT}"
echo "[benchmark] Native H2 server log: ${SERVER_LOG}"
