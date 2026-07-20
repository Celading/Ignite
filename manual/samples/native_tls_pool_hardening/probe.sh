#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
OUT="${IGNITE_NATIVE_TLS_POOL_OUT:-/tmp/ignite-native-tls-pool-hardening}"
TURNS="${IGNITE_NATIVE_TLS_POOL_TURNS:-512}"
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

descendants() {
  local root="$1"
  local pending=("${root}")
  local all=("${root}")
  while [[ "${#pending[@]}" -gt 0 ]]; do
    local parent="${pending[0]}"
    pending=("${pending[@]:1}")
    while IFS= read -r child; do
      [[ -z "${child}" ]] && continue
      all+=("${child}")
      pending+=("${child}")
    done < <(pgrep -P "${parent}" 2>/dev/null || true)
  done
  printf '%s\n' "${all[@]}"
}

client_test_pid() {
  local root="$1"
  while IFS= read -r pid; do
    local command
    command="$(ps -o command= -p "${pid}" 2>/dev/null || true)"
    if [[ "${command}" == *"/unittest_bin/ignite.client"* ]]; then
      printf '%s\n' "${pid}"
      return
    fi
  done < <(descendants "${root}")
}

process_rss_kib() {
  local value
  value="$(ps -o rss= -p "$1" 2>/dev/null | tr -d ' ' || true)"
  printf '%s\n' "${value:-0}"
}

process_lsof_count() {
  local mode="$1"
  local pid="$2"
  local count
  if [[ "${mode}" == "tcp" ]]; then
    count="$(lsof -nP -a -p "${pid}" -iTCP 2>/dev/null | tail -n +2 | wc -l | tr -d ' ' || true)"
  else
    count="$(lsof -nP -p "${pid}" 2>/dev/null | tail -n +2 | wc -l | tr -d ' ' || true)"
  fi
  printf '%s\n' "${count:-0}"
}

process_lsof_snapshot() {
  local pid="$1"
  local file="$2"
  lsof -nP -p "${pid}" > "${file}" 2>/dev/null || true
}

run_profile() {
  local heap="$1"
  local log="${OUT}/test-${heap}.log"
  local start_marker="${OUT}/start-${heap}.marker"
  local marker="${OUT}/settled-${heap}.marker"
  rm -f "${start_marker}" "${marker}"
  echo "[native-tls-pool] heap=${heap} turns=${TURNS}"
  (
    cd "${ROOT}"
    exec env cjHeapSize="${heap}" IGNITE_NATIVE_TLS_POOL_TURNS="${TURNS}" \
      IGNITE_NATIVE_TLS_POOL_START_MS=1000 \
      IGNITE_NATIVE_TLS_POOL_START_MARKER="${start_marker}" \
      IGNITE_NATIVE_TLS_POOL_SETTLE_MS=1000 \
      IGNITE_NATIVE_TLS_POOL_SETTLE_MARKER="${marker}" \
      cjpm test --skip-build \
      --filter NativeTlsPoolPressureInternalTestSuite \
      --no-progress --no-capture-output
  ) > "${log}" 2>&1 &
  CURRENT_PID="$!"

  local peak_rss=0
  local peak_fd=0
  local peak_tcp=0
  local baseline_rss=0
  local baseline_fd=0
  local baseline_tcp=0
  local settled_rss=0
  local settled_fd=0
  local settled_tcp=0
  local baseline_sampled=0
  local proof_sampled=0
  while kill -0 "${CURRENT_PID}" 2>/dev/null; do
    local test_pid
    test_pid="$(client_test_pid "${CURRENT_PID}")"
    if [[ -n "${test_pid}" ]]; then
      local rss fd tcp
      rss="$(process_rss_kib "${test_pid}")"
      fd="$(process_lsof_count fd "${test_pid}")"
      tcp="$(process_lsof_count tcp "${test_pid}")"
      [[ "${rss}" -gt "${peak_rss}" ]] && peak_rss="${rss}"
      [[ "${fd}" -gt "${peak_fd}" ]] && peak_fd="${fd}"
      [[ "${tcp}" -gt "${peak_tcp}" ]] && peak_tcp="${tcp}"
      if [[ "${baseline_sampled}" == "0" ]] && [[ -f "${start_marker}" ]]; then
        # The marker may appear while the preceding lsof calls are running.
        # Resample after observing it so baseline is not a pre-marker snapshot.
        baseline_rss="$(process_rss_kib "${test_pid}")"
        baseline_fd="$(process_lsof_count fd "${test_pid}")"
        baseline_tcp="$(process_lsof_count tcp "${test_pid}")"
        process_lsof_snapshot "${test_pid}" "${OUT}/baseline-lsof-${heap}.txt"
        baseline_sampled=1
      fi
      if [[ "${proof_sampled}" == "0" ]] && [[ -f "${marker}" ]]; then
        # Do not reuse counts collected before the settle marker existed.
        settled_rss="$(process_rss_kib "${test_pid}")"
        settled_fd="$(process_lsof_count fd "${test_pid}")"
        settled_tcp="$(process_lsof_count tcp "${test_pid}")"
        process_lsof_snapshot "${test_pid}" "${OUT}/settled-lsof-${heap}.txt"
        proof_sampled=1
      fi
    fi
    sleep 0.02
  done

  local status=0
  wait "${CURRENT_PID}" || status="$?"
  CURRENT_PID=""
  local proof
  proof="$(grep '\[native-tls-pool-pressure\]' "${log}" | tail -1 || true)"
  if [[ "${proof_sampled}" == "0" ]]; then
    settled_rss=0
    settled_fd=0
    settled_tcp=0
  fi
  local result="heap=${heap} status=${status} turnsPerProtocol=${TURNS} metricScope=ignite.client baselineRssKiB=${baseline_rss} peakRssKiB=${peak_rss} settledRssKiB=${settled_rss} baselineFd=${baseline_fd} peakFd=${peak_fd} settledFd=${settled_fd} baselineTcp=${baseline_tcp} peakTcp=${peak_tcp} settledTcp=${settled_tcp}"
  printf '%s\n' "${result}" | tee -a "${OUT}/summary.txt"
  printf '%s\n' "proof=${proof}" | tee -a "${OUT}/summary.txt"
  if [[ "${status}" != "0" ]] || [[ -z "${proof}" ]] || \
     [[ "${baseline_sampled}" != "1" ]] || [[ "${proof_sampled}" != "1" ]] || \
     [[ "${settled_fd}" -gt "${baseline_fd}" ]] || \
     [[ "${settled_tcp}" -gt "${baseline_tcp}" ]]; then
    tail -120 "${log}" >&2
    return 1
  fi
}

cd "${ROOT}"
if [[ "${IGNITE_NATIVE_TLS_POOL_SKIP_BUILD:-0}" != "1" ]]; then
  cjpm test --no-run
fi
run_profile "256mb"
run_profile "512mb"
echo "[native-tls-pool] receipt=${OUT}/summary.txt"
