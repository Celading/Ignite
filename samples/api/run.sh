#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
"${ROOT}/samples/_shared/run_server_sample.sh" "samples/api/main.cj" "/tmp/ignite_sample_api"
