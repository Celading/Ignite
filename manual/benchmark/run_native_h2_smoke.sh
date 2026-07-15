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

IGNITE_BENCH_URL="http://127.0.0.1:18880/plaintext" \
IGNITE_BENCH_LABEL="ignite0800-native-h2-node-smoke" \
IGNITE_BENCH_VERSION="IgniteNEXT" \
IGNITE_BENCH_BACKEND="native-h2" \
IGNITE_BENCH_TRACK="internal" \
IGNITE_BENCH_PROFILE="interop-smoke" \
IGNITE_BENCH_IMPLEMENTATION="ignite-native-h2" \
IGNITE_BENCH_SCENARIO="plaintext" \
IGNITE_BENCH_PROTOCOL="http/h2" \
IGNITE_BENCH_CAVEATS="interop-only|local-loopback|no-performance-claim" \
IGNITE_BENCH_CONCURRENCY="${IGNITE_BENCH_CONCURRENCY:-8}" \
IGNITE_BENCH_WARMUP="${IGNITE_BENCH_WARMUP:-0.25}" \
IGNITE_BENCH_DURATION="${IGNITE_BENCH_DURATION:-1}" \
IGNITE_BENCH_EXPECTED_BYTES="14" \
IGNITE_BENCH_OUTPUT="${OUTPUT}" \
  node "${ROOT}/manual/benchmark/load.mjs"

echo "[benchmark] Native H2 smoke result: ${OUTPUT}"
echo "[benchmark] Native H2 server log: ${SERVER_LOG}"
