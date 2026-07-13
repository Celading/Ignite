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

if [[ "${IGNITE_BENCH_APPEND:-0}" != "1" ]]; then
  : >"${OUTPUT}"
fi
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

SCENARIOS="${IGNITE_BENCH_SCENARIOS:-plaintext:14 json:50 bytes/64k:65536}"
CONCURRENCIES="${IGNITE_BENCH_CONCURRENCIES:-${IGNITE_BENCH_CONCURRENCY:-32}}"

for concurrency in ${CONCURRENCIES}; do
  for scenario in ${SCENARIOS}; do
    path="${scenario%%:*}"
    expected_bytes="${scenario##*:}"
    echo "[benchmark] running /${path} concurrency=${concurrency}"
    IGNITE_BENCH_URL="http://${HOST}:${PORT}/${path}" \
    IGNITE_BENCH_LABEL="ignite0800-${IGNITE_BENCH_BACKEND:-native}-${path//\//-}-c${concurrency}-${IGNITE_BENCH_RUN_LABEL:-r1}" \
    IGNITE_BENCH_VERSION="${IGNITE_BENCH_VERSION:-IgniteNEXT}" \
    IGNITE_BENCH_BACKEND="${IGNITE_BENCH_BACKEND:-native}" \
    IGNITE_BENCH_TRACK="${IGNITE_BENCH_TRACK:-public}" \
    IGNITE_BENCH_PROFILE="${IGNITE_BENCH_PROFILE:-balanced}" \
    IGNITE_BENCH_IMPLEMENTATION="${IGNITE_BENCH_IMPLEMENTATION:-ignite-${IGNITE_BENCH_BACKEND:-native}}" \
    IGNITE_BENCH_SCENARIO="${path//\//-}" \
    IGNITE_BENCH_PROTOCOL="${IGNITE_BENCH_PROTOCOL:-http/h1}" \
    IGNITE_BENCH_CAVEATS="${IGNITE_BENCH_CAVEATS:-local-loopback|cpu-affinity-uncontrolled|power-state-uncontrolled|compiler-optimization-uncontrolled}" \
    IGNITE_BENCH_CONCURRENCY="${concurrency}" \
    IGNITE_BENCH_EXPECTED_BYTES="${expected_bytes}" \
    IGNITE_BENCH_REQUEST_TIMEOUT_MS="${IGNITE_BENCH_REQUEST_TIMEOUT_MS:-5000}" \
    IGNITE_BENCH_OUTPUT="${OUTPUT}" \
      node "${ROOT}/manual/benchmark/load.mjs"
  done
done

echo "[benchmark] result: ${OUTPUT}"
echo "[benchmark] server log: ${SERVER_LOG}"
