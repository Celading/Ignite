#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
HOST="127.0.0.1"
PORT="18880"
OUTPUT="${IGNITE_BENCH_OUTPUT:-/tmp/ignite0800-benchmark.jsonl}"
SERVER_LOG="${IGNITE_BENCH_SERVER_LOG:-/tmp/ignite0800-benchmark-server.log}"
SERVER_BIN="${IGNITE_BENCH_SERVER_BIN:-/tmp/ignite0800_benchmark_server}"

cleanup() {
  if [[ -n "${SERVER_PID:-}" ]]; then
    kill "${SERVER_PID}" 2>/dev/null || true
    wait "${SERVER_PID}" 2>/dev/null || true
  fi
}
trap cleanup EXIT INT TERM

: >"${OUTPUT}"
echo "[benchmark] building and starting IgniteNEXT (${IGNITE_BENCH_BACKEND:-native})..."
"${ROOT}/manual/samples/_shared/run_server_sample.sh" \
  "manual/benchmark/main.cj" "${SERVER_BIN}" >"${SERVER_LOG}" 2>&1 &
SERVER_PID=$!

for _ in $(seq 1 120); do
  if curl -fsS "http://${HOST}:${PORT}/health" >/dev/null 2>&1; then
    break
  fi
  if ! kill -0 "${SERVER_PID}" 2>/dev/null; then
    echo "[benchmark] server exited before readiness; log follows:" >&2
    sed -n '1,240p' "${SERVER_LOG}" >&2
    exit 1
  fi
  sleep 0.25
done

if ! curl -fsS "http://${HOST}:${PORT}/health" >/dev/null; then
  echo "[benchmark] server did not become ready; log follows:" >&2
  sed -n '1,240p' "${SERVER_LOG}" >&2
  exit 1
fi

for path in plaintext json bytes/64k; do
  echo "[benchmark] running /${path}"
  IGNITE_BENCH_URL="http://${HOST}:${PORT}/${path}" \
  IGNITE_BENCH_OUTPUT="${OUTPUT}" \
    node "${ROOT}/manual/benchmark/load.mjs"
done

echo "[benchmark] result: ${OUTPUT}"
echo "[benchmark] server log: ${SERVER_LOG}"
