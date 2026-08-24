#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PROFILE="${IGNITE_BENCH_PROFILE:-balanced}"
OUTPUT="${IGNITE_BENCH_OUTPUT:-/tmp/ignite-public-benchmark-v2-${PROFILE}.jsonl}"
ROUNDS="${IGNITE_BENCH_ROUNDS:-2}"

if [[ -n "${IGNITE_BENCH_VERSION:-}" ]]; then
  VERSION="${IGNITE_BENCH_VERSION}"
else
  VERSION="$(git -C "${ROOT}" rev-parse --short=12 HEAD 2>/dev/null || echo unknown)"
  if [[ -n "$(git -C "${ROOT}" status --porcelain 2>/dev/null)" ]]; then
    VERSION="${VERSION}+dirty"
  fi
fi

case "${PROFILE}" in
  balanced)
    DEFAULT_SCENARIOS="plaintext:14 json:50 bytes/64k:65536 bytes/256k:262144 bytes/1024k:1048576"
    DEFAULT_CONCURRENCIES="1 8 32 128"
    ;;
  concurrency-stress)
    DEFAULT_SCENARIOS="plaintext:14 json:50 bytes/64k:65536"
    DEFAULT_CONCURRENCIES="64 256 1024"
    ;;
  *)
    echo "[public-benchmark] unknown IGNITE_BENCH_PROFILE=${PROFILE}; expected balanced or concurrency-stress" >&2
    exit 2
    ;;
esac

SCENARIOS="${IGNITE_BENCH_SCENARIOS:-${DEFAULT_SCENARIOS}}"
CONCURRENCIES="${IGNITE_BENCH_CONCURRENCIES:-${DEFAULT_CONCURRENCIES}}"

: >"${OUTPUT}"

if [[ "${IGNITE_SAMPLE_SKIP_BUILD:-0}" != "1" ]]; then
  echo "[public-benchmark] building the current Ignite checkout once before the interleaved matrix"
  (cd "${ROOT}" && cjpm build)
fi

run_cell() {
  local backend="$1"
  local round="$2"
  local scenario="$3"
  local concurrency="$4"
  echo "[public-benchmark] backend=${backend} round=${round} scenario=${scenario} concurrency=${concurrency}"
  env \
    IGNITE_SAMPLE_SKIP_BUILD=1 \
    IGNITE_BENCH_BACKEND="${backend}" \
    IGNITE_BENCH_PROFILE="${PROFILE}" \
    IGNITE_BENCH_APPEND=1 \
    IGNITE_BENCH_OUTPUT="${OUTPUT}" \
    IGNITE_BENCH_SCENARIOS="${scenario}" \
    IGNITE_BENCH_CONCURRENCIES="${concurrency}" \
    IGNITE_BENCH_RUN_LABEL="${round}" \
    IGNITE_BENCH_VERSION="${VERSION}" \
    "${ROOT}/manual/benchmark/run.sh"
}

for concurrency in ${CONCURRENCIES}; do
  for scenario in ${SCENARIOS}; do
    run_cell native r1 "${scenario}" "${concurrency}"
    run_cell stdx r1 "${scenario}" "${concurrency}"
    if [[ "${ROUNDS}" -ge 2 ]]; then
      run_cell stdx r2 "${scenario}" "${concurrency}"
      run_cell native r2 "${scenario}" "${concurrency}"
    fi
  done
done

echo "[public-benchmark] result: ${OUTPUT}"
