#!/usr/bin/env bash
# "Build" for a GDScript-only Godot project means: validate it imports and
# boots cleanly. There is no compilation step at this stage. This script
# exists as the stable entry point that scripts_dev/export_android.sh and CI
# (if added later) can depend on, and will grow if/when native modules or
# GDExtension are introduced.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "BUILD: running validate.sh..."
"$REPO_ROOT/scripts_dev/validate.sh"

echo "BUILD: OK - project validated. No packaging step defined yet."
echo "BUILD: for an Android APK, use scripts_dev/export_android.sh."
