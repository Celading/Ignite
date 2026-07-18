#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
WORK="${IGNITE_ZSTD_INTEROP_ROOT:-/tmp/ignite-zstd-interop}"
BIN="${WORK}/zstd-interop"

mkdir -p "${WORK}"
export IGNITE_ZSTD_INTEROP_ROOT="${WORK}"
"${ROOT}/manual/samples/_shared/run_server_sample.sh" \
  "manual/samples/zstd_interop/main.cj" \
  "${BIN}"

zstd -q -t "${WORK}/buffered.zst"
zstd -q -t "${WORK}/streamed.zst"
zstd -q -d -c "${WORK}/buffered.zst" | cmp - "${WORK}/buffered.raw"
zstd -q -d -c "${WORK}/streamed.zst" | cmp - "${WORK}/streamed.raw"

echo "buffered=accepted;streamed=accepted;decoder=zstd-cli;result=accepted"
