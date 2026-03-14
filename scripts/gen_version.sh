#!/usr/bin/env sh
# Generate src/version.cj from cjpm.toml [package] version.
# Run from repo root after changing version in cjpm.toml.
# Usage: ./scripts/gen_version.sh [path/to/cjpm.toml]

set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TOML="${1:-$ROOT/cjpm.toml}"
OUT="$ROOT/src/version.cj"

if [ ! -f "$TOML" ]; then
  echo "gen_version.sh: not found: $TOML" >&2
  exit 1
fi

# Extract first occurrence of version = "x.y.z" under [package]
V="$(sed -n '/^\[package\]/,/^\[/p' "$TOML" | grep -E '^\s*version\s*=' | head -1 | sed -E 's/^[^"]*"([^"]+)".*/\1/')"
if [ -z "$V" ]; then
  echo "gen_version.sh: could not find version in $TOML" >&2
  exit 1
fi

mkdir -p "$(dirname "$OUT")"
cat > "$OUT" << EOF
package ignite

// Generated from cjpm.toml by scripts/gen_version.sh. Do not edit by hand.
/// Framework version (synced with cjpm.toml); used by banner, debug, etc.
public func getFrameworkVersion(): String {
    "${V}"
}
EOF
echo "gen_version.sh: wrote getFrameworkVersion() = ${V} -> $OUT"
