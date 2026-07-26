#!/usr/bin/env bash
# Export an Android APK from the command line.
#
# STATUS: Not yet verified on Android/Termux/Ubuntu (proot-distro). See
# docs/android_build.md. This script fails clearly and explains what's
# missing rather than silently doing nothing or fabricating success. It
# should work unmodified on a PC with Godot Editor + Android SDK set up
# (Milestone 16).
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

OUT_PATH="${1:-build/breathe-debug.apk}"

fail() { echo "EXPORT_ANDROID: FAIL - $1" >&2; exit 1; }

GODOT_BIN="$(command -v godot4 || command -v godot || true)"
[ -n "$GODOT_BIN" ] || fail "no godot4/godot binary on PATH (see docs/setup.md)"

export GODOT_SILENCE_ROOT_WARNING=1

# Export templates must be installed for the currently running Godot version.
# Version string looks like "4.7.1.stable.official.a13da4feb" - templates
# live under a directory named "4.7.1.stable" (the part before .official/.custom_build).
GODOT_VERSION="$("$GODOT_BIN" --headless --version 2>/dev/null | sed -E 's/\.(official|custom_build).*$//')"
TEMPLATE_DIR="$HOME/.local/share/godot/export_templates/${GODOT_VERSION}"
if [ ! -d "$TEMPLATE_DIR" ]; then
  fail "export templates not found at $TEMPLATE_DIR
  Download with:
    gh api repos/godotengine/godot/releases/latest --jq '.assets[] | select(.name | test(\"export_templates.tpz\$\")) | .browser_download_url'
  then extract the .tpz (it's a zip) into: $TEMPLATE_DIR/
  This is a ~1.2GB download - see docs/android_build.md before doing this on a constrained device."
fi

command -v java >/dev/null 2>&1 || fail "java not found - Android export needs a JDK. See docs/android_build.md."

if [ ! -f "$REPO_ROOT/export_presets.cfg" ]; then
  fail "export_presets.cfg not found - no Android export preset configured yet.
  Set this up in the Godot Editor (Project > Export > Add... > Android) and commit
  export_presets.cfg (or configure it manually), then re-run this script.
  See docs/android_build.md for the current plan (this is expected to happen on PC)."
fi

mkdir -p "$(dirname "$OUT_PATH")"
echo "EXPORT_ANDROID: exporting debug APK to $OUT_PATH ..."
"$GODOT_BIN" --headless --path "$REPO_ROOT" --export-debug "Android" "$OUT_PATH"
echo "EXPORT_ANDROID: OK - $OUT_PATH"
