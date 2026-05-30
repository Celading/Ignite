#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
WORKER_BIN="/tmp/ignite_sample_handlefortest"
LOG_DIR="/tmp/ignite_sample_handlefortest_probe_${$}"
WORKERS="${IGNITE_HANDLE_FOR_TEST_PROBE_WORKERS:-6}"
ITERATIONS="${IGNITE_HANDLE_FOR_TEST_PROBE_ITERATIONS:-24}"
LEASE_ROOT="${IGNITE_HANDLE_FOR_TEST_PROBE_LEASE_DIR:-/tmp/ignite_handle_for_test_probe_lease_${$}}"

detect_stdx_static() {
  if [[ -n "${IGNITE_STDX_STATIC:-}" && -d "${IGNITE_STDX_STATIC}" ]]; then
    printf '%s\n' "${IGNITE_STDX_STATIC}"
    return 0
  fi

  if [[ -n "${CANGJIE_STDX_PATH:-}" && -d "${CANGJIE_STDX_PATH}" ]]; then
    local hit
    hit="$(find "${CANGJIE_STDX_PATH}" -maxdepth 4 -type d -path "*/cj_stdx_*_llvm/static" | head -n 1)"
    if [[ -n "${hit}" ]]; then
      printf '%s\n' "${hit}"
      return 0
    fi
  fi

  return 1
}

detect_runtime_lib_dir() {
  if [[ -n "${IGNITE_CJ_RUNTIME_LIB_DIR:-}" && -d "${IGNITE_CJ_RUNTIME_LIB_DIR}" ]]; then
    printf '%s\n' "${IGNITE_CJ_RUNTIME_LIB_DIR}"
    return 0
  fi

  if [[ -n "${CANGJIE_HOME:-}" && -d "${CANGJIE_HOME}/runtime/lib" ]]; then
    local hit
    hit="$(find "${CANGJIE_HOME}/runtime/lib" -maxdepth 3 -type f -name "libcangjie-runtime.*" | head -n 1)"
    if [[ -n "${hit}" ]]; then
      dirname "${hit}"
      return 0
    fi
  fi

  return 1
}

mkdir -p "${LOG_DIR}"

cleanup() {
  rm -rf "${LEASE_ROOT}" >/dev/null 2>&1 || true
}
trap cleanup EXIT

# First try shared runner; may fail due to stale link flags in _shared/.
IGNITE_SAMPLE_COMPILE_ONLY=1 \
  "${ROOT}/manual/samples/_shared/run_server_sample.sh" \
  "manual/samples/handlefortest/main.cj" \
  "${WORKER_BIN}" 2>/dev/null || true

STDX_STATIC="$(detect_stdx_static || true)"
if [[ -z "${STDX_STATIC}" ]]; then
  echo "[sample/handlefortest] cannot locate stdx static path." >&2
  exit 1
fi

RUNTIME_LIB_DIR="$(detect_runtime_lib_dir || true)"
if [[ -z "${RUNTIME_LIB_DIR}" ]]; then
  echo "[sample/handlefortest] cannot locate Cangjie runtime lib dir." >&2
  exit 1
fi

# Note: run_server_sample.sh above may miss some link flags.
# Probe compilation requires libignite.binary and libjinguissl base.
# We re-link the worker with the missing libs.
IGNITE_SAMPLE_SKIP_BUILD=1 IGNITE_SAMPLE_COMPILE_ONLY=1 \
  "${ROOT}/manual/samples/_shared/run_server_sample.sh" \
  "manual/samples/handlefortest/main.cj" \
  "${WORKER_BIN}" 2>/dev/null || true
# If the shared runner succeeded, we're done; if it failed due to missing libs,
# compile directly with the full link set.
if [[ ! -x "${WORKER_BIN}" ]]; then
  echo "[sample/handlefortest] recompiling with full link flags..." >&2
  cjc "${ROOT}/manual/samples/handlefortest/main.cj" \
    --import-path "${ROOT}/target/release" \
    --import-path "${STDX_STATIC}" \
    -L "${ROOT}/target/release/ignite" \
    -L "${ROOT}/target/release/lisi" \
    -L "${ROOT}/target/release/jinguissl" \
    -L "${STDX_STATIC}/stdx" \
    -lignite.middleware -lignite.governance -lignite.client -lignite \
    -lignite.api2 -lignite.security -lignite.api2.GetData -lignite.binary \
    -llisi.transport -llisi.runtime -llisi.net.TlsTool -llisi.net \
    -llisi.logger -llisi.term -llisi \
    -ljinguissl.contract -ljinguissl.crypto.tls -ljinguissl.crypto.x509 \
    -ljinguissl.crypto.ssh -ljinguissl.crypto.rsa -ljinguissl.crypto.ed25519 \
    -ljinguissl.crypto.x25519 -ljinguissl.crypto.ecc -ljinguissl.crypto.digest \
    -ljinguissl.crypto.chacha20 -ljinguissl.crypto.aes -ljinguissl.crypto.utils \
    -ljinguissl.crypto.compliance -ljinguissl.crypto.bignum -ljinguissl.crypto.error \
    -ljinguissl \
    -lstdx.encoding.json -lstdx.serialization.serialization -lstdx.net.http \
    -lstdx.net.tls -lstdx.net.tls.common -lstdx.logger -lstdx.log \
    -lstdx.encoding.url -lstdx.encoding.json.stream -lstdx.crypto.x509 \
    -lstdx.crypto.keys -lstdx.encoding.hex -lstdx.crypto.crypto \
    -lstdx.crypto.digest -lstdx.crypto.common -lstdx.encoding.base64 \
    -lstdx.compress.zlib \
    -Woff unused \
    -o "${WORKER_BIN}"
fi

case "$(uname -s)" in
  Darwin)
    export DYLD_LIBRARY_PATH="${ROOT}/target/release/ignite:${ROOT}/target/release/jinguissl:${ROOT}/target/release/lisi:${STDX_STATIC}/stdx:${RUNTIME_LIB_DIR}:${DYLD_LIBRARY_PATH:-}"
    ;;
  Linux)
    export LD_LIBRARY_PATH="${ROOT}/target/release/ignite:${ROOT}/target/release/jinguissl:${ROOT}/target/release/lisi:${STDX_STATIC}/stdx:${RUNTIME_LIB_DIR}:${LD_LIBRARY_PATH:-}"
    ;;
esac

declare -a pids=()
declare -a logs=()

for i in $(seq 1 "${WORKERS}"); do
  log_path="${LOG_DIR}/worker-${i}.log"
  logs+=("${log_path}")
  IGNITE_INPROC_TEST_PORT_LEASE_DIR="${LEASE_ROOT}" \
  IGNITE_HANDLE_FOR_TEST_STRESS_ID="worker-${i}" \
  IGNITE_HANDLE_FOR_TEST_STRESS_ITERATIONS="${ITERATIONS}" \
  "${WORKER_BIN}" >"${log_path}" 2>&1 &
  pids+=("$!")
done

failed=0
for idx in "${!pids[@]}"; do
  if ! wait "${pids[$idx]}"; then
    failed=1
    echo "[sample/handlefortest] worker $((idx + 1)) failed: ${logs[$idx]}" >&2
    sed -n '1,160p' "${logs[$idx]}" >&2
  fi
done

if [[ "${failed}" != "0" ]]; then
  echo "[sample/handlefortest] probe failed. logs: ${LOG_DIR}" >&2
  exit 1
fi

ok_count="$(grep -h "ok$" "${LOG_DIR}"/worker-*.log | wc -l | tr -d ' ')"
echo "[sample/handlefortest] probe passed workers=${WORKERS} iterations=${ITERATIONS} ok_logs=${ok_count}"
echo "[sample/handlefortest] worker logs: ${LOG_DIR}"
