# Current Status

_Last updated: 2026-07-28_

## CURRENT MILESTONE

Milestone 17 — Gameplay Pivot: Two-Entity Orbit Core (Concept v2) — code
complete, Editor GUI playtest of `orbit_prototype.tscn` outstanding

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
Milestone 17 — PARTIALLY COMPLETED (OrbitController + EnergyBond + PlayerPair
all implemented, wired, and headlessly tested, 206/206; Editor GUI playtest
of orbit_prototype.tscn not yet done - see NEXT ACTION)

## BRANCH

`main`

## LATEST STABLE COMMIT

`8479f5b` — feat: recover and verify OrbitController for two-entity orbit
pivot (Milestone 17)

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
- **Same-day follow-up**: user opened `project.godot` in the real Godot
  4.7.1 Editor GUI on this PC and confirmed it imports/opens correctly
  (first genuine Editor-GUI open of this project, closing out that part of
  Milestone 14's long-outstanding acceptance criteria). Implemented
  `EnergyBond` (`scripts/player/energy_bond.gd`) and `PlayerPair`
  (`scripts/player/player_pair.gd` + `.tscn`), completing the
  `BreathingController -> OrbitController -> PlayerPair -> EnergyBond` data
  flow for the pivot. Added a standalone playtest harness
  (`scripts/player/orbit_prototype.gd`/`.tscn`) so the pair can be run in
  isolation (Editor F6) without touching `world.tscn`/`main_scene` - the
  old `Player`/`World` single-entity flow is completely untouched.
  `tests/test_energy_bond.gd` (14/14) and `tests/test_player_pair.gd`
  (23/23) added, following the exact conventions of the existing suite.
  Full suite: **206/206 assertions, 18 files**. A throwaway (uncommitted)
  headless sanity check separately confirmed `orbit_prototype.tscn` itself
  instantiates and runs 30 simulated steps without error - entities stay
  diametrically opposite, the pair rises while "holding," and the bond's
  geometry/width update correctly.
  **Not yet done**: nobody has opened `orbit_prototype.tscn` in the Editor
  GUI and pressed F6 to actually see/feel it run - that's the immediate
  next step (see NEXT ACTION).

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

- **`orbit_prototype.tscn` in the Editor GUI** (F6 "Run Current Scene") -
  headlessly verified only so far; nobody has visually confirmed the two
  entities orbit correctly, the bond reads well, or hold/release feels
  responsive.
- Android SDK / export template setup - still not done on this PC.
- Everything already flagged as outstanding in Milestones 5, 6, 8, 9, 11,
  12 for the **old** single-Player flow (visual/feel verification,
  autoload-gated code paths, real audio content) - these are on hold along
  with Milestones 15/16, not actively being pursued right now.

## KNOWN ISSUES

- `godot4` isn't on PATH on this PC - the downloaded binary lives in an
  awkwardly-named folder under `Downloads\`. Worked around with a
  gitignored `.local_bin/godot4` shim (see `docs/setup.md`); worth moving
  to a stable location eventually.
- The old single-Player visual/feel/audio-content backlog (Milestones 5,
  6, 8, 9, 11, 12) is on hold, not resolved - see ROADMAP.md.

## BLOCKERS

None. Development is on PC with a working Editor and headless CLI both
verified functional.

## NEXT ACTION

Open `scripts/player/orbit_prototype.tscn` in the Godot Editor and press
F6 ("Run Current Scene") to manually playtest the new two-entity orbit
pivot: confirm the two entities visibly orbit the shared center, the
energy bond bows/brightens on hold and relaxes on release, and the pair
rises while holding / falls while released. Report anything that looks or
feels wrong before continuing to Milestone 18 (orbital-orientation input,
obstacles for the pair, wiring `PlayerPair` into `World`).

## NEXT ENVIRONMENT

`[PC-GODOT]` — continue here; both Editor GUI and headless CLI are
verified working on this machine.
