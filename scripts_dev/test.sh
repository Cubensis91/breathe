#!/usr/bin/env bash
# Run the headless GDScript test suite under tests/.
#
# Convention: each tests/test_*.gd extends SceneTree, does its own
# assertions in _initialize(), prints a "<name>: N passed, M failed"
# summary line, and calls quit(0) on success / quit(1) on failure. This
# script runs each one via `godot4 --headless -s <file>`, fails if any of
# them exit non-zero, and aggregates each file's own summary line into a
# total assertion count across the whole suite. See docs/development_workflow.md
# ("Writing tests") for the full convention new test files should follow.
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
total_passed=0
total_failed=0
for f in "${test_files[@]}"; do
  echo "TEST: running $f ..."
  set +e
  output="$("$GODOT_BIN" --headless --path "$REPO_ROOT" -s "res://$f" 2>&1)"
  status=$?
  set -e
  echo "$output"

  # Parse this file's own "<name>: N passed, M failed" summary line so the
  # suite can report a total assertion count, not just a per-file pass/fail.
  summary_line="$(echo "$output" | grep -E '^[A-Za-z_]+: [0-9]+ passed, [0-9]+ failed$' | tail -1 || true)"
  if [ -n "$summary_line" ]; then
    file_passed="$(echo "$summary_line" | grep -oE '[0-9]+ passed' | grep -oE '[0-9]+')"
    file_failed="$(echo "$summary_line" | grep -oE '[0-9]+ failed' | grep -oE '[0-9]+')"
    total_passed=$((total_passed + file_passed))
    total_failed=$((total_failed + file_failed))
  fi

  if [ "$status" -eq 0 ]; then
    echo "TEST: $f PASSED"
  else
    echo "TEST: $f FAILED" >&2
    failures=$((failures + 1))
  fi
done

echo "TEST: TOTAL $total_passed passed, $total_failed failed, across ${#test_files[@]} file(s)"

if [ "$failures" -gt 0 ]; then
  echo "TEST: FAILED - $failures test file(s) failed" >&2
  exit 1
fi

echo "TEST: ALL PASSED (${#test_files[@]} test file(s))"
