#!/usr/bin/env bash
# Run the headless GDScript test suite under tests/.
#
# Convention: each tests/test_*.gd extends SceneTree, does its own
# assertions in _initialize(), prints a summary, and calls quit(0) on
# success / quit(1) on failure. This script runs each one via
# `godot4 --headless -s <file>` and fails if any of them exit non-zero.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

GODOT_BIN="$(command -v godot4 || command -v godot || true)"
if [ -z "$GODOT_BIN" ]; then
  echo "TEST: FAIL - no godot4/godot binary on PATH (see docs/setup.md)" >&2
  exit 1
fi
export GODOT_SILENCE_ROOT_WARNING=1

echo "TEST: booting project headlessly..."
if ! "$GODOT_BIN" --headless --path "$REPO_ROOT" --quit; then
  echo "TEST: FAIL - project failed to boot headlessly" >&2
  exit 1
fi

shopt -s nullglob
test_files=(tests/test_*.gd)
shopt -u nullglob

if [ "${#test_files[@]}" -eq 0 ]; then
  echo "TEST: no GDScript tests under tests/ yet."
  echo "TEST: PASSED (boot check only)"
  exit 0
fi

failures=0
for f in "${test_files[@]}"; do
  echo "TEST: running $f ..."
  if "$GODOT_BIN" --headless --path "$REPO_ROOT" -s "res://$f"; then
    echo "TEST: $f PASSED"
  else
    echo "TEST: $f FAILED" >&2
    failures=$((failures + 1))
  fi
done

if [ "$failures" -gt 0 ]; then
  echo "TEST: FAILED - $failures test file(s) failed" >&2
  exit 1
fi

echo "TEST: ALL PASSED (${#test_files[@]} test file(s))"
