#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO="${XMRIG_REPO:-git@github.com:xmrig/xmrig.git}"
REF="${XMRIG_REF:-v6.26.0}"
SRC_DIR="${XMRIG_SOURCE_DIR:-$ROOT_DIR/.vendor/xmrig}"
BUILD_DIR="${XMRIG_BUILD_DIR:-$ROOT_DIR/build}"
JOBS="${XMRIG_JOBS:-$(getconf _NPROCESSORS_ONLN 2>/dev/null || printf 2)}"

usage() { printf 'Usage: %s [--clean] [--repo URL] [--ref TAG]\n' "$0"; }
CLEAN=0
while (($#)); do
  case "$1" in
    --clean) CLEAN=1; shift;;
    --repo) REPO="$2"; shift 2;;
    --ref) REF="$2"; shift 2;;
    -h|--help) usage; exit 0;;
    *) printf 'Unknown option: %s\n' "$1" >&2; usage >&2; exit 2;;
  esac
done

for tool in git cmake; do
  command -v "$tool" >/dev/null 2>&1 || { echo "Missing required tool: $tool" >&2; exit 1; }
done
command -v c++ >/dev/null 2>&1 || { echo 'Missing C++ compiler (install build-essential or Xcode Command Line Tools).' >&2; exit 1; }

mkdir -p "$(dirname "$SRC_DIR")"
if [[ ! -d "$SRC_DIR/.git" ]]; then
  echo "Cloning $REPO at $REF via SSH..."
  git clone --depth 1 --branch "$REF" "$REPO" "$SRC_DIR"
else
  echo "Updating existing source checkout..."
  git -C "$SRC_DIR" fetch --depth 1 origin "$REF"
  git -C "$SRC_DIR" checkout --detach FETCH_HEAD
fi

if (( CLEAN )); then rm -rf "$BUILD_DIR"; fi
cmake -S "$SRC_DIR" -B "$BUILD_DIR" -DCMAKE_BUILD_TYPE=Release -DWITH_HWLOC=OFF
cmake --build "$BUILD_DIR" --config Release --parallel "$JOBS"

BIN="$BUILD_DIR/xmrig"
[[ -x "$BIN" ]] || BIN="$BUILD_DIR/Release/xmrig"
printf '\nBuild complete: %s\n' "$BIN"
printf 'Run with your local config: %s -c %s\n' "$BIN" "$ROOT_DIR/config.local.json"
