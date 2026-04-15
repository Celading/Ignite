#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
SERVER_BIN="/tmp/ignite_sample_h2wire"
SERVER_LOG="/tmp/ignite_sample_h2wire.log"
TLS_GUARD_BIN="/tmp/ignite_sample_h2wire_tls_guard"
TLS_GUARD_LOG_ROOT="/tmp/ignite_sample_h2wire_tls_guard"
VERIFY_SCRIPT="${ROOT}/manual/samples/h2wire/verify_http2.mjs"

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

cleanup() {
  if [[ -n "${SERVER_PID:-}" ]]; then
    kill "${SERVER_PID}" >/dev/null 2>&1 || true
    wait "${SERVER_PID}" 2>/dev/null || true
  fi
}
trap cleanup EXIT

if ! command -v node >/dev/null 2>&1; then
  echo "[sample/h2wire] node is required for the built-in HTTP/2 probe." >&2
  exit 1
fi

if [[ -z "${IGNITE_SAMPLE_TLS_CERT:-}" && -f "${ROOT}/../_helper/testdata/tls/server-cert-a.pem" ]]; then
  export IGNITE_SAMPLE_TLS_CERT="${ROOT}/../_helper/testdata/tls/server-cert-a.pem"
fi
if [[ -z "${IGNITE_SAMPLE_TLS_KEY:-}" && -f "${ROOT}/../_helper/testdata/tls/server-key-a.pem" ]]; then
  export IGNITE_SAMPLE_TLS_KEY="${ROOT}/../_helper/testdata/tls/server-key-a.pem"
fi

IGNITE_SAMPLE_COMPILE_ONLY=1 "${ROOT}/manual/samples/_shared/run_server_sample.sh" "manual/samples/h2wire/main.cj" "${SERVER_BIN}"
IGNITE_SAMPLE_SKIP_BUILD=1 IGNITE_SAMPLE_COMPILE_ONLY=1 \
  "${ROOT}/manual/samples/_shared/run_server_sample.sh" \
  "manual/samples/h2wire/tls_guard.cj" \
  "${TLS_GUARD_BIN}"

STDX_STATIC="$(detect_stdx_static || true)"
if [[ -z "${STDX_STATIC}" ]]; then
  echo "[sample/h2wire] cannot locate stdx static path." >&2
  exit 1
fi

RUNTIME_LIB_DIR="$(detect_runtime_lib_dir || true)"
if [[ -z "${RUNTIME_LIB_DIR}" ]]; then
  echo "[sample/h2wire] cannot locate Cangjie runtime lib dir." >&2
  exit 1
fi

case "$(uname -s)" in
  Darwin)
    export DYLD_LIBRARY_PATH="${ROOT}/target/release/ignite:${ROOT}/target/release/jinguissl:${STDX_STATIC}/stdx:${RUNTIME_LIB_DIR}:${DYLD_LIBRARY_PATH:-}"
    ;;
  Linux)
    export LD_LIBRARY_PATH="${ROOT}/target/release/ignite:${ROOT}/target/release/jinguissl:${STDX_STATIC}/stdx:${RUNTIME_LIB_DIR}:${LD_LIBRARY_PATH:-}"
    ;;
esac

run_guard_stage() {
  local stage="$1"
  local log_path="${TLS_GUARD_LOG_ROOT}_${stage}.log"
  if ! IGNITE_H2_TLS_GUARD_STAGE="${stage}" "${TLS_GUARD_BIN}" >"${log_path}" 2>&1; then
    echo "[sample/h2wire] isolated TLS guard failed at stage=${stage} before server launch." >&2
    echo "[sample/h2wire] inspect ${log_path}" >&2
    sed -n '1,160p' "${log_path}" >&2
    return 1
  fi
}

run_guard_stage "precheck"
run_guard_stage "cert_decode"
run_guard_stage "key_decode"
run_guard_stage "stdx_build"

"${SERVER_BIN}" >"${SERVER_LOG}" 2>&1 &
SERVER_PID="$!"

ready=0
for _ in $(seq 1 50); do
  if ! kill -0 "${SERVER_PID}" >/dev/null 2>&1; then
    echo "[sample/h2wire] server exited before probe could connect." >&2
    echo "[sample/h2wire] this usually means the current stdx TLS build path aborted during startup after the isolated guard had passed." >&2
    echo "[sample/h2wire] inspect ${SERVER_LOG}" >&2
    sed -n '1,160p' "${SERVER_LOG}" >&2
    exit 1
  fi
  if curl -k --http2 --silent --fail "https://127.0.0.1:18444/health" >/dev/null 2>&1; then
    ready=1
    break
  fi
  sleep 0.1
done

if [[ "${ready}" != "1" ]]; then
  echo "[sample/h2wire] health probe never became ready." >&2
  echo "[sample/h2wire] inspect ${SERVER_LOG}" >&2
  sed -n '1,160p' "${SERVER_LOG}" >&2
  exit 1
fi

node "${VERIFY_SCRIPT}"

echo "[sample/h2wire] probe passed. server log: ${SERVER_LOG}"
