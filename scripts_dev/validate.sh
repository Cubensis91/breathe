#!/usr/bin/env bash
# Validate that the local toolchain and project can actually run.
# Fails fast and clearly on missing prerequisites. Portable across
# Android/Ubuntu (proot-distro) and PC as long as `godot4`/`godot` is on PATH.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

fail() { echo "VALIDATE: FAIL - $1" >&2; exit 1; }
ok()   { echo "VALIDATE: OK   - $1"; }

command -v git >/dev/null 2>&1 || fail "git not found on PATH"
ok "git found: $(git --version)"

GODOT_BIN="$(command -v godot4 || command -v godot || true)"
[ -n "$GODOT_BIN" ] || fail "no godot4/godot binary on PATH (see docs/setup.md)"
ok "godot binary found: $GODOT_BIN"

export GODOT_SILENCE_ROOT_WARNING=1
"$GODOT_BIN" --headless --version >/dev/null 2>&1 \
  || fail "godot binary failed to run --headless --version"
ok "godot headless execution works ($("$GODOT_BIN" --headless --version))"

[ -f "$REPO_ROOT/project.godot" ] || fail "project.godot not found at repo root"
ok "project.godot present"

"$GODOT_BIN" --headless --path "$REPO_ROOT" --quit >/tmp/breathe_validate_boot.log 2>&1 \
  || fail "project failed to boot headlessly (see /tmp/breathe_validate_boot.log)"
ok "project boots headlessly without error"

echo "VALIDATE: ALL CHECKS PASSED"
