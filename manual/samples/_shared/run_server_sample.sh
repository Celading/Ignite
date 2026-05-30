#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "usage: $0 <sample-source> <output-bin>" >&2
  exit 1
fi

SAMPLE_SOURCE="$1"
OUTPUT_BIN="$2"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

if [[ ! -f "${ROOT}/${SAMPLE_SOURCE}" ]]; then
  echo "[sample-runner] sample source not found: ${SAMPLE_SOURCE}" >&2
  exit 1
fi

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

STDX_STATIC="$(detect_stdx_static || true)"
if [[ -z "${STDX_STATIC}" ]]; then
  echo "[sample-runner] cannot locate stdx static path." >&2
  echo "[sample-runner] set IGNITE_STDX_STATIC=/path/to/cj_stdx_*_llvm/static or CANGJIE_STDX_PATH." >&2
  exit 1
fi

RUNTIME_LIB_DIR="$(detect_runtime_lib_dir || true)"
if [[ -z "${RUNTIME_LIB_DIR}" ]]; then
  echo "[sample-runner] cannot locate Cangjie runtime lib dir." >&2
  echo "[sample-runner] set IGNITE_CJ_RUNTIME_LIB_DIR or CANGJIE_HOME." >&2
  exit 1
fi

COMMON_IMPORTS=(
  --import-path "${ROOT}/target/release"
  --import-path "${ROOT}/target/release/seajson"
  --import-path "${STDX_STATIC}"
)
COMMON_LINKS=(
  -L "${ROOT}/target/release/seajson"
  -lseajson
  -L "${ROOT}/target/release/ignite"
  -lignite.middleware
  -lignite.governance
  -lignite.client
  -lignite
  -lignite.api2
  -lignite.binary
  -lignite.security
  -L "${ROOT}/target/release/jinguissl_contract"
  -ljinguissl_contract.jinguissl.contract
  -ljinguissl_contract.jinguissl.live
  -ljinguissl_contract.jinguissl.runtime
  -L "${ROOT}/target/release/jinguissl_core"
  -ljinguissl_core.jinguissl.crypto.tls
  -ljinguissl_core.jinguissl.crypto.x509
  -ljinguissl_core.jinguissl.crypto.ssh
  -ljinguissl_core.jinguissl.crypto.kem
  -ljinguissl_core.jinguissl.crypto.rsa
  -ljinguissl_core.jinguissl.crypto.ed25519
  -ljinguissl_core.jinguissl.crypto.ecc
  -ljinguissl_core.jinguissl.crypto.x25519
  -ljinguissl_core.jinguissl.crypto.digest
  -ljinguissl_core.jinguissl.crypto.chacha20
  -ljinguissl_core.jinguissl.crypto.aes
  -ljinguissl_core.jinguissl.crypto.utils
  -ljinguissl_core.jinguissl.crypto.compliance
  -ljinguissl_core.jinguissl.crypto.bignum
  -ljinguissl_core.jinguissl.crypto.sm4
  -ljinguissl_core.jinguissl.crypto.sm3
  -ljinguissl_core.jinguissl.crypto.error
  -L "${STDX_STATIC}/stdx"
  -lstdx.encoding.json
  -lstdx.serialization.serialization
  -lstdx.net.http
  -lstdx.net.tls
  -lstdx.net.tls.common
  -lstdx.logger
  -lstdx.log
  -lstdx.encoding.url
  -lstdx.encoding.json.stream
  -lstdx.crypto.x509
  -lstdx.crypto.keys
  -lstdx.encoding.hex
  -lstdx.crypto.crypto
  -lstdx.crypto.digest
  -lstdx.crypto.common
  -lstdx.encoding.base64
  -lstdx.compress.zlib
)

if [[ "${IGNITE_SAMPLE_SKIP_BUILD:-0}" == "1" ]]; then
  echo "[sample-runner] skipping ignite package build (IGNITE_SAMPLE_SKIP_BUILD=1)"
else
  echo "[sample-runner] building ignite package..."
  (cd "${ROOT}" && cjpm build)
fi

echo "[sample-runner] compiling ${SAMPLE_SOURCE}..."
cjc "${ROOT}/${SAMPLE_SOURCE}" \
  "${COMMON_IMPORTS[@]}" \
  "${COMMON_LINKS[@]}" \
  -Woff unused \
  -o "${OUTPUT_BIN}"

if [[ "${IGNITE_SAMPLE_COMPILE_ONLY:-0}" == "1" ]]; then
  echo "[sample-runner] compile-only mode; skipping run"
  exit 0
fi

case "$(uname -s)" in
  Darwin)
    export DYLD_LIBRARY_PATH="${ROOT}/target/release/seajson:${ROOT}/target/release/ignite:${STDX_STATIC}/stdx:${RUNTIME_LIB_DIR}:${DYLD_LIBRARY_PATH:-}"
    ;;
  Linux)
    export LD_LIBRARY_PATH="${ROOT}/target/release/seajson:${ROOT}/target/release/ignite:${STDX_STATIC}/stdx:${RUNTIME_LIB_DIR}:${LD_LIBRARY_PATH:-}"
    ;;
esac

echo "[sample-runner] running ${OUTPUT_BIN}"
"${OUTPUT_BIN}"
