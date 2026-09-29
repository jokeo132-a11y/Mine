#!/usr/bin/env bash
set -Eeuo pipefail
ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
BIN="${XMRIG_BINARY:-$ROOT_DIR/build/xmrig}"
if [[ ! -x "$BIN" ]]; then
  echo 'Build not found; building first...'
  "$ROOT_DIR/build.sh"
fi
exec "$BIN" -c "$ROOT_DIR/config.local.json" "$@"
