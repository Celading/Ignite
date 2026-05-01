#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
OUT_BIN="/tmp/ignite_sample_server_socket_double_accept_experiment"

ensure_cangjie_env() {
  if ! command -v cjpm >/dev/null 2>&1 || ! command -v cjc >/dev/null 2>&1; then
    local envsetup=""
    if [[ -n "${IGNITE_CANGJIE_HOME:-}" && -f "${IGNITE_CANGJIE_HOME}/envsetup.sh" ]]; then
      envsetup="${IGNITE_CANGJIE_HOME}/envsetup.sh"
    elif [[ -n "${CANGJIE_HOME:-}" && -f "${CANGJIE_HOME}/envsetup.sh" ]]; then
      envsetup="${CANGJIE_HOME}/envsetup.sh"
    elif [[ -f "/Library/Frameworks/Cangjie/1.1.0-nightly/envsetup.sh" ]]; then
      envsetup="/Library/Frameworks/Cangjie/1.1.0-nightly/envsetup.sh"
    fi

    if [[ -n "${envsetup}" ]]; then
      export DYLD_LIBRARY_PATH="${DYLD_LIBRARY_PATH:-}"
      # shellcheck disable=SC1090
      source "${envsetup}"
    fi
  fi

  if [[ -z "${SDKROOT:-}" ]] && command -v xcrun >/dev/null 2>&1; then
    export SDKROOT
    SDKROOT="$(xcrun --sdk macosx --show-sdk-path)"
  fi

  if [[ -z "${CANGJIE_STDX_PATH:-}" && -d "/Library/Frameworks/Cangjie/stdx_Build" ]]; then
    export CANGJIE_STDX_PATH="/Library/Frameworks/Cangjie/stdx_Build"
  fi
}

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

collect_package_archives() {
  local dir="$1"
  if [[ ! -d "${dir}" ]]; then
    return 0
  fi

  find "${dir}" -maxdepth 1 -type f -name "lib*.a" \
    ! -name "lib*.tests.a" \
    | sort
}

ensure_cangjie_env

STDX_STATIC="$(detect_stdx_static || true)"
if [[ -z "${STDX_STATIC}" ]]; then
  echo "[double-accept-experiment] cannot locate stdx static path." >&2
  echo "[double-accept-experiment] set IGNITE_STDX_STATIC=/path/to/cj_stdx_*_llvm/static or CANGJIE_STDX_PATH." >&2
  exit 1
fi

RUNTIME_LIB_DIR="$(detect_runtime_lib_dir || true)"
if [[ -z "${RUNTIME_LIB_DIR}" ]]; then
  echo "[double-accept-experiment] cannot locate Cangjie runtime lib dir." >&2
  echo "[double-accept-experiment] set IGNITE_CJ_RUNTIME_LIB_DIR or CANGJIE_HOME." >&2
  exit 1
fi

COMMON_IMPORTS=(
  --import-path "${ROOT}/target/release"
  --import-path "${ROOT}/target/release/ignite"
  --import-path "${ROOT}/target/release/lisi"
  --import-path "${ROOT}/target/release/jinguissl"
  --import-path "${STDX_STATIC}"
)

IGNITE_ARCHIVES=()
while IFS= read -r path; do
  IGNITE_ARCHIVES+=("${path}")
done < <(collect_package_archives "${ROOT}/target/release/ignite")

LISI_ARCHIVES=()
while IFS= read -r path; do
  LISI_ARCHIVES+=("${path}")
done < <(collect_package_archives "${ROOT}/target/release/lisi")

JINGUISSL_ARCHIVES=()
while IFS= read -r path; do
  JINGUISSL_ARCHIVES+=("${path}")
done < <(collect_package_archives "${ROOT}/target/release/jinguissl")

STDX_ARCHIVES=()
while IFS= read -r path; do
  STDX_ARCHIVES+=("${path}")
done < <(collect_package_archives "${STDX_STATIC}/stdx")

COMMON_LINKS=(
  "${IGNITE_ARCHIVES[@]}"
  "${LISI_ARCHIVES[@]}"
  "${JINGUISSL_ARCHIVES[@]}"
  "${STDX_ARCHIVES[@]}"
)

if [[ "${IGNITE_SAMPLE_SKIP_BUILD:-0}" != "1" ]]; then
  echo "[double-accept-experiment] building ignite package..."
  (cd "${ROOT}" && cjpm build)
else
  echo "[double-accept-experiment] skipping ignite package build (IGNITE_SAMPLE_SKIP_BUILD=1)"
fi

echo "[double-accept-experiment] compiling sample..."
cjc "${ROOT}/manual/samples/server_socket_double_accept_experiment/main.cj" \
  "${COMMON_IMPORTS[@]}" \
  "${COMMON_LINKS[@]}" \
  -Woff unused \
  -o "${OUT_BIN}"

if [[ "${IGNITE_SAMPLE_COMPILE_ONLY:-0}" == "1" ]]; then
  echo "[double-accept-experiment] compile-only mode; skipping run"
  exit 0
fi

case "$(uname -s)" in
  Darwin)
    export DYLD_LIBRARY_PATH="${ROOT}/target/release/ignite:${STDX_STATIC}/stdx:${RUNTIME_LIB_DIR}:${DYLD_LIBRARY_PATH:-}"
    ;;
  Linux)
    export LD_LIBRARY_PATH="${ROOT}/target/release/ignite:${STDX_STATIC}/stdx:${RUNTIME_LIB_DIR}:${LD_LIBRARY_PATH:-}"
    ;;
esac

echo "[double-accept-experiment] running sample..."
"${OUT_BIN}"
