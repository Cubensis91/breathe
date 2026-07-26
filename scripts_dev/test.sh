#!/usr/bin/env bash
# Run the headless-testable portion of the test suite.
#
# Current scope (Milestone 2): boots the project headlessly and confirms no
# errors. As Milestone 13 (Automated Validation and Testing) adds real
# GDScript tests under tests/, this script will invoke them via a headless
# Godot test runner script. Kept intentionally small until there's actual
# test content to run.
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

test_files=(tests/*.gd)
if [ -e "${test_files[0]}" ]; then
  echo "TEST: found GDScript test files but no test runner is wired up yet."
  echo "TEST: this is expected until Milestone 13 - update this script then."
else
  echo "TEST: no GDScript tests under tests/ yet (expected pre-Milestone 13)."
fi

echo "TEST: PASSED (boot check only, at current milestone)"
