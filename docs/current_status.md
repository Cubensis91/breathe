# Current Status

_Last updated: 2026-07-28_

## CURRENT MILESTONE

Milestone 17 — Gameplay Pivot: Two-Entity Orbit Core (Concept v2)

## STATUS

Milestone 0 — COMPLETED
Milestone 1 — COMPLETED
Milestone 2 — COMPLETED (superseded: `bootstrap.tscn` deleted, `world.tscn`
is now `main_scene`)
Milestone 3 — COMPLETED (state layer only — see ROADMAP.md note)
Milestone 4 — COMPLETED
Milestone 5 — PARTIALLY COMPLETED (logic done and tested; touch feel unverified)
Milestone 6 — PARTIALLY COMPLETED (logic/wiring done and tested; visual feel unverified)
Milestone 7 — COMPLETED (rule) — runtime wiring landed in Milestone 8
Milestone 8 — PARTIALLY COMPLETED (logic/wiring done and tested; visual feel unverified)
Milestone 9 — PARTIALLY COMPLETED (logic/wiring done and tested; visual feel unverified)
Milestone 10 — COMPLETED
Milestone 11 — PARTIALLY COMPLETED (logic done and tested where headlessly
possible; full-flow and visual feel unverified)
Milestone 12 — PARTIALLY COMPLETED (routing/settings logic done and
tested; no real audio assets exist yet - genuine content gap)
Milestone 13 — COMPLETED
Milestone 14 — PARTIALLY COMPLETED (everything verifiable from Termux/
Ubuntu is done; opening in the actual Godot Editor GUI is inherently
untestable from here)
Milestone 15 — ON HOLD (superseded pending gameplay pivot validation)
Milestone 16 — ON HOLD (superseded pending gameplay pivot validation)
Milestone 17 — PARTIALLY COMPLETED (`OrbitController` implemented, bug-fixed,
and tested; not yet wired into a scene/PlayerPair/EnergyBond)

## BRANCH

`main`

## LATEST STABLE COMMIT

(pending — this session's commit not yet made at time of writing; see
`git log` for the actual latest hash)

## PC SESSION — 2026-07-28

Development continues on a Windows 11 PC (Godot 4.7.1 stable win64,
verified headless via `.local_bin/godot4`, see `docs/setup.md`). This is the
first PC session; prior work was Termux/Ubuntu CLI-only.

- Verified local repo was already in sync with `origin/main` (`fc5a4f9`, no
  divergence, nothing to pull).
- Found `scripts/player/orbit_controller.gd` and
  `tests/test_orbit_controller.gd` already present in the working tree,
  fully written, but **never committed on any branch** (confirmed via
  `git log --all`) — genuine uncommitted work-in-progress toward the new
  two-entity orbit/energy-bond gameplay direction (see ROADMAP.md
  Milestone 17). Preserved and verified rather than discarded.
- Ran the full headless suite for the first time on this PC: found and fixed
  a real bug in `test_orbit_controller.gd` (illegal `.free()` calls on
  `RefCounted` objects that silently hung the test runner instead of
  failing loudly). Full suite now passes: **169/169 assertions, 16 files**.
- The core gameplay concept is pivoting: from a single-Player vertical-scroll
  design to "TWO BEINGS. ONE BREATH. ONE ENERGY BOND. ONE ASCENT." — see
  ROADMAP.md Milestone 17 for what's landed and what's still open
  (`EnergyBond`, `PlayerPair`, orbital-orientation input, vertical ascent
  integration, first obstacle pass for the pair).

## COMPLETED

- Milestones 0-13: see ROADMAP.md and earlier CHANGELOG entries.
- **Milestone 14 — PC handoff verification:**
  - Genuine fresh `git clone` of `Cubensis91/breathe` into a clean
    directory (not a re-check of the working copy) - `validate.sh`,
    `test.sh` (148/148), and `build.sh` all pass identically from the
    clone; `scripts_dev/*.sh` executable bits survive; `assets/*/.gitkeep`
    present.
  - Grepped the whole tracked tree for hardcoded machine-specific absolute
    paths - none found. Checked for stray `TODO`/`FIXME`/`XXX` markers in
    `scripts/`/`tests/` - none found.
  - Refreshed `docs/pc_handoff.md`: Milestone 12 -> 13 references updated,
    `class_name`/`preload()` explanation now correctly points at
    `docs/development_workflow.md` (permanent home) instead of
    `docs/current_status.md` (rolling snapshot that drops old detail),
    added real-audio-asset sourcing to PC tasks, recorded the fresh-clone
    verification itself.
  - Spot-checked `README.md`/`ARCHITECTURE.md` - both evergreen/principle
    documents, still accurate, no changes needed.

## TESTED

- Fresh clone: `scripts_dev/validate.sh`, `test.sh` (148 assertions, 15
  files), `build.sh` - all pass identically to the working copy.
- `grep` across tracked files for this device's absolute paths
  (`/root/breathe`, `/root/.local`) - zero matches.
- `grep` for `TODO`/`FIXME`/`XXX` in `scripts/`/`tests/` - zero matches.

## NOT TESTED

- Godot Editor GUI (deferred to PC) - **this is Milestone 14's own
  acceptance criteria that cannot be met from this environment.** There is
  no display server here; only the headless CLI has ever run this
  project. A PC session opening `project.godot` in the real Editor is the
  first genuine test of "opens cleanly."
- Android SDK / export template setup.
- Everything already flagged as outstanding in Milestones 5, 6, 8, 9, 11,
  12 (visual/feel verification, autoload-gated code paths, real audio
  content).

## KNOWN ISSUES

- RAM is tight on this device (~700 MiB "available" observed during
  discovery). Avoid heavy concurrent processes when running Godot.
- The visual/feel/audio-content backlog (Milestones 5, 6, 8, 9, 11, 12)
  continues to be the dominant open item, and Milestone 14 confirms it
  can't be closed from here - it genuinely needs a human on a PC or
  Android device.

## BLOCKERS

None for continuing code-first development. Opening the project in the
actual Godot Editor is `BLOCKED — REQUIRES PC` (not a code issue - this
environment has no display server).

## NEXT ACTION

Milestone 15 (Visual Integration and Polish) explicitly requires PC and
cannot be started from here. Milestone 16 (Android Build and Release)
likewise. At this point, the highest-value next action is for the user to
actually open this project on a PC (or get Android export tooling sorted)
and go through the accumulated verification backlog - not to continue
further code-only milestones, since the remaining ROADMAP items are
either PC-gated or would be building further on unverified feel.

## NEXT ENVIRONMENT

`[PC-GODOT]` — this is the natural stopping point for code-first,
Termux/Ubuntu-only progress until a PC/Android session happens
