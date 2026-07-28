# Setup / Environment Discovery

Last verified: 2026-07-26, on-device (Termux → Ubuntu 26.04 proot-distro).

This document records the **actual verified** state of the development
environment. Nothing here is assumed — everything was checked by running the
corresponding command. Re-run these checks if the device or Ubuntu rootfs
changes.

## System

| Item | Value |
|---|---|
| Host | Android device via Termux, `proot-distro` running Ubuntu |
| Kernel | `Linux localhost 6.17.0-PRoot-Distro` |
| Ubuntu | 26.04 LTS "Resolute Raccoon" |
| Architecture | `aarch64` / `arm64` (`dpkg --print-architecture` → `arm64`) |
| CPUs | 8 |
| RAM | 3.4 GiB total; ~700 MiB "available" at time of check (tight — other
  proot processes were using memory); 4 GiB swap configured |
| Disk | 110 GB total, 54 GB available on `/` |

**Implication:** RAM is tight under load. Avoid running the Godot Editor GUI
on-device; headless CLI operations are the target workflow here. Close other
work before running anything memory-heavy.

## Git / GitHub

| Item | Value |
|---|---|
| `git --version` | 2.53.0 |
| `gh --version` | 2.46.0 |
| `git config user.name` | `Cubensis91` |
| `git config user.email` | `fetimus31@gmail.com` |
| `gh auth status` | Logged in as `Cubensis91`, token scopes: `gist`,
  `read:org`, `repo`, `workflow` |

GitHub CLI is authenticated and has the `repo` scope needed to create and
push to repositories. No manual token setup was required.

## Godot

| Item | Value |
|---|---|
| System package (`apt-cache search godot`) | Only `godot3*` packages
  available in the Ubuntu repos — **not** Godot 4.x. Not used. |
| Godot 4.x binary | Downloaded directly from the official GitHub release:
  `godotengine/godot` tag `4.7.1-stable`, asset
  `Godot_v4.7.1-stable_linux.arm64.zip` |
| Install location | `/root/.local/opt/godot/godot4` (added to `PATH` via
  `~/.bashrc`) |
| Headless execution | **Verified working**: `godot4 --headless --version`
  → `4.7.1.stable.official.a13da4feb`, exit code 0 |
| Dependency fix required | Initial run failed with
  `libfontconfig.so.1: cannot open shared object file`. Fixed by
  `apt-get install -y libfontconfig1` (pulled in `fontconfig-config`,
  `libfreetype6`, `fonts-dejavu-core`/`mono` as dependencies). |
| Editor GUI | Not tested — not expected to be usable/necessary on-device
  given RAM constraints and lack of a display server in this environment.
  Editor-driven work is deferred to PC. |

Godot 4.x ships a single binary per platform that supports `--headless`
directly (unlike Godot 3, which needed a separate `-server` build). This is
why the standard `linux.arm64.zip` editor build is sufficient for CLI/headless
validation here — no separate "server" download was needed.

To re-download or update:
```bash
gh api repos/godotengine/godot/releases/latest --jq '.assets[] | select(.name | test("linux.arm64.zip$")) | .browser_download_url'
```

## Android SDK / Build Tooling

| Item | Value |
|---|---|
| Java | Not installed. `openjdk-25-jdk-headless` is available via `apt` if
  needed later. |
| Android SDK | Not installed. `android-sdk` (28.0.2+12) is available via
  `apt` as a candidate, but this is Debian's repackaged SDK, not Google's —
  needs verification before relying on it for a real Android build/export. |
| `adb` | Not found. Not installed. |
| Godot Android export templates | **Not downloaded.** The official
  `Godot_v4.7.1-stable_export_templates.tpz` asset is ~1.2 GB — deferred
  until Milestone 16 (Android Build) is actually reached, to avoid an
  unnecessary large download/storage commitment during bootstrap. |

**Implication:** Full on-device APK export (Godot Android export templates +
Android SDK build-tools + signing) has **not** been attempted or proven
feasible on this arm64 proot-distro environment. It is plausible in
principle (Godot 4 supports Linux arm64 hosts for export in recent versions)
but is explicitly deferred — see `docs/android_build.md` and
`docs/pc_handoff.md`. This is not treated as a blocker for code-first
development; only for the final export step, which can happen on a PC.

## PC (Windows) — added 2026-07-28

| Item | Value |
|---|---|
| Host | Windows 11 Home, PowerShell 5.1 + Git Bash both available |
| `git --version` | 2.55.0.windows.3 |
| Godot 4.x binary | `Godot_v4.7.1-stable_win64.exe` downloaded from the official
  GitHub release, under `Downloads\Godot_v4.7.1-stable_win64.exe\` — note this
  is a **directory** (the zip's top-level folder kept the `.exe`-looking name),
  containing `Godot_v4.7.1-stable_win64.exe` and `..._console.exe` inside. Not
  on `PATH`. |
| Headless execution | **Verified working**: `Godot_v4.7.1-stable_win64_console.exe --version --headless` → `4.7.1.stable.official.a13da4feb` |
| `godot4` shim | `.local_bin/godot4` (gitignored, per-environment — same
  convention as this file already documents) wraps the console binary above,
  so `scripts_dev/*.sh` run unmodified under Git Bash: add `.local_bin` to
  `PATH` for the Git Bash session, e.g. `export PATH="$PWD/.local_bin:$PATH"`. |
| `scripts_dev/*.sh` | Confirmed to run as-is under Git Bash (no Windows-specific changes needed) once the shim above is on `PATH`. |
| Android SDK / export templates | Not yet set up on this machine — see `docs/android_build.md`, Milestone 16/18. |

**Implication:** unlike the Termux/Ubuntu install, the actual Godot binary
here isn't at a stable, predictable path — it's wherever the browser download
landed. Moving/renaming it to a fixed location (and updating `.local_bin/godot4`
to match) is worth doing before relying on this long-term; flagged here rather
than done automatically since it touches files outside the repo.

## Verified Pipeline (Milestone 0)

```
Termux
  ↓ (proot-distro run ubuntu, this session)
Ubuntu 26.04 (aarch64)
  ↓
git 2.53.0 / gh 2.46.0 (authenticated)
  ↓
GitHub (Cubensis91/breathe created and reachable)
  ↓
Godot 4.7.1 CLI (--headless verified working)
  ↓
Android SDK / export templates — NOT YET SET UP (deferred to Milestone 16)
```

Everything up to and including headless Godot CLI execution is verified.
Android export is the first stage explicitly marked
`BLOCKED — REQUIRES PC` (or requires further investigation) until proven
otherwise.
