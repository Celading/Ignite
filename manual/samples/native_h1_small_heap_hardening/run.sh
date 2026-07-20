#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

exec "${ROOT}/manual/samples/_shared/run_server_sample.sh" \
  "manual/samples/native_h1_small_heap_hardening/main.cj" \
  "/tmp/ignite_sample_native_h1_small_heap_hardening"
