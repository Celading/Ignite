#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
WORK="${IGNITE_BROTLI_INTEROP_ROOT:-/tmp/ignite-brotli-interop}"
BIN="${WORK}/brotli-interop"

mkdir -p "${WORK}"
export IGNITE_BROTLI_INTEROP_ROOT="${WORK}"
"${ROOT}/manual/samples/_shared/run_server_sample.sh" \
  "manual/samples/brotli_interop/main.cj" \
  "${BIN}"

brotli -t "${WORK}/buffered.br"
brotli -t "${WORK}/streamed.br"
brotli -t "${WORK}/short-3.br"
brotli -t "${WORK}/short-32.br"
brotli -t "${WORK}/empty.br"
brotli -d -c "${WORK}/buffered.br" | cmp - "${WORK}/buffered.raw"
brotli -d -c "${WORK}/streamed.br" | cmp - "${WORK}/streamed.raw"
brotli -d -c "${WORK}/short-3.br" | cmp - "${WORK}/short-3.raw"
brotli -d -c "${WORK}/short-32.br" | cmp - "${WORK}/short-32.raw"
brotli -d -c "${WORK}/empty.br" | cmp - "${WORK}/empty.raw"
for length in 3 4 5 6 7 8 9 10 11 13 15 19 23 31 39 55 71 103 135 199 327 583 1095 2119; do
  brotli -t "${WORK}/boundary-${length}.br"
  brotli -d -c "${WORK}/boundary-${length}.br" | cmp - "${WORK}/boundary-${length}.raw"
done

buffered_encoded="$(wc -c < "${WORK}/buffered.br" | tr -d ' ')"
streamed_encoded="$(wc -c < "${WORK}/streamed.br" | tr -d ' ')"
if (( buffered_encoded >= 65536 || streamed_encoded >= 131172 )); then
  echo "brotli output did not provide compression gain" >&2
  exit 1
fi

echo "buffered=accepted;streamed=accepted;short=accepted;boundaries=24/24;empty=accepted;decoder=brotli-cli;gain=accepted;result=accepted"
