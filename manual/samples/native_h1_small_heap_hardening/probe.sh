#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
OUT="${IGNITE_HQ0856_OUT:-/tmp/ignite-hq0856-small-heap}"
ROUNDS="${IGNITE_HQ0856_ROUNDS:-40}"
CURRENT_PID=""

mkdir -p "${OUT}"
: > "${OUT}/summary.txt"

cleanup() {
  if [[ -n "${CURRENT_PID}" ]] && kill -0 "${CURRENT_PID}" 2>/dev/null; then
    kill "${CURRENT_PID}" 2>/dev/null || true
    wait "${CURRENT_PID}" 2>/dev/null || true
  fi
}
trap cleanup EXIT

measure_rss_kib() {
  local pid="$1"
  local value
  value="$(ps -o rss= -p "${pid}" | tr -d ' ' || true)"
  if [[ -z "${value}" ]]; then
    value="0"
  fi
  printf '%s\n' "${value}"
}

measure_fd_count() {
  local pid="$1"
  if ! command -v lsof >/dev/null 2>&1; then
    printf '%s\n' "unavailable"
    return
  fi
  lsof -nP -p "${pid}" 2>/dev/null | wc -l | tr -d ' '
}

measure_tcp_count() {
  local pid="$1"
  if ! command -v lsof >/dev/null 2>&1; then
    printf '%s\n' "unavailable"
    return
  fi
  local value
  value="$(lsof -nP -a -p "${pid}" -iTCP 2>/dev/null | wc -l | tr -d ' ' || true)"
  printf '%s\n' "${value}"
}

wait_ready() {
  local base="$1"
  local attempts=0
  while [[ "${attempts}" -lt 200 ]]; do
    if curl -fsS --http1.1 --max-time 1 "${base}/poll" >/dev/null 2>&1; then
      return 0
    fi
    sleep 0.05
    attempts=$((attempts + 1))
  done
  return 1
}

run_profile() {
  local heap="$1"
  local port="$2"
  local base="http://127.0.0.1:${port}"
  local log="${OUT}/server-${heap}.log"
  local errors_file="${OUT}/errors-${heap}.log"
  : > "${errors_file}"

  echo "[hq0856] starting heap=${heap} port=${port} rounds=${ROUNDS}"
  (
    cd "${ROOT}"
    exec env \
      cjHeapSize="${heap}" \
      IGNITE_HQ0856_PORT="${port}" \
      IGNITE_SAMPLE_SKIP_BUILD=1 \
      ./manual/samples/native_h1_small_heap_hardening/run.sh
  ) > "${log}" 2>&1 &
  CURRENT_PID="$!"

  if ! wait_ready "${base}"; then
    echo "[hq0856] server failed readiness heap=${heap}" >&2
    tail -80 "${log}" >&2
    return 1
  fi

  local rss_before
  local rss_peak
  local rss_after
  local fd_before
  local fd_after
  local tcp_before
  local tcp_after
  rss_before="$(measure_rss_kib "${CURRENT_PID}")"
  rss_peak="${rss_before}"
  fd_before="$(measure_fd_count "${CURRENT_PID}")"
  tcp_before="$(measure_tcp_count "${CURRENT_PID}")"

  local round=0
  while [[ "${round}" -lt "${ROUNDS}" ]]; do
    (curl -fsS --http1.1 --max-time 3 "${base}/hold" >/dev/null || echo hold >> "${errors_file}") &
    local hold_one="$!"
    (curl -fsS --http1.1 --max-time 3 "${base}/hold" >/dev/null || echo hold >> "${errors_file}") &
    local hold_two="$!"

    if ! curl -fsS --http1.1 --max-time 3 -o /dev/null \
      "${base}/poll" "${base}/poll" "${base}/poll" "${base}/poll" \
      "${base}/poll" "${base}/poll" "${base}/poll" "${base}/poll" \
      >/dev/null; then
      echo poll >> "${errors_file}"
    fi
    if ! curl -fsS --http1.1 --max-time 3 "${base}/large" >/dev/null; then
      echo large >> "${errors_file}"
    fi

    wait "${hold_one}" || true
    wait "${hold_two}" || true

    local current_rss
    current_rss="$(measure_rss_kib "${CURRENT_PID}")"
    if [[ "${current_rss}" -gt "${rss_peak}" ]]; then
      rss_peak="${current_rss}"
    fi
    round=$((round + 1))
  done

  sleep 1
  local endpoint_snapshot
  local settled_snapshot
  endpoint_snapshot="$(curl -fsS --http1.1 --max-time 3 "${base}/metrics")"
  sleep 1
  settled_snapshot="$(grep '\[hq0856-runtime\].*\"requestQueueDepth\":0}' "${log}" | tail -1 || true)"
  rss_after="$(measure_rss_kib "${CURRENT_PID}")"
  fd_after="$(measure_fd_count "${CURRENT_PID}")"
  tcp_after="$(measure_tcp_count "${CURRENT_PID}")"

  local error_count
  error_count="$(wc -l < "${errors_file}" | tr -d ' ')"
  local request_count=$((ROUNDS * 11))
  local result
  result="heap=${heap} requests=${request_count} errors=${error_count} rssBeforeKiB=${rss_before} rssPeakKiB=${rss_peak} rssAfterKiB=${rss_after} fdBefore=${fd_before} fdAfter=${fd_after} tcpBefore=${tcp_before} tcpAfter=${tcp_after}"
  printf '%s\n' "${result}" | tee -a "${OUT}/summary.txt"
  printf '%s\n' "endpointSnapshot=${endpoint_snapshot}" | tee -a "${OUT}/summary.txt"
  printf '%s\n' "settledSnapshot=${settled_snapshot}" | tee -a "${OUT}/summary.txt"

  if [[ "${error_count}" != "0" ]]; then
    echo "[hq0856] request errors observed heap=${heap}" >&2
    return 1
  fi
  if [[ "${settled_snapshot}" != *'"selectedBackend":"ignite-native-h1"'* ]] ||
     [[ "${settled_snapshot}" != *'"activeConnections":0'* ]] ||
     [[ "${settled_snapshot}" != *'"activeKeepAliveConnections":0'* ]] ||
     [[ "${settled_snapshot}" != *'"inFlightRequests":0'* ]]; then
    echo "[hq0856] runtime counters did not settle heap=${heap}" >&2
    return 1
  fi

  kill "${CURRENT_PID}" 2>/dev/null || true
  wait "${CURRENT_PID}" 2>/dev/null || true
  CURRENT_PID=""
}

cd "${ROOT}"
if [[ "${IGNITE_HQ0856_SKIP_BUILD:-0}" != "1" ]]; then
  cjpm build
else
  echo "[hq0856] skipping package build; using the caller-verified target tree"
fi
run_profile "256mb" 18893
run_profile "512mb" 18894

echo "[hq0856] receipt=${OUT}/summary.txt"
