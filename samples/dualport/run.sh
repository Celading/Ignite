#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
"${ROOT}/samples/_shared/run_server_sample.sh" "samples/dualport/main.cj" "/tmp/ignite_sample_dualport"
