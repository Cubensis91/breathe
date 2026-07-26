# Current Status

_Last updated: 2026-07-26_

## CURRENT MILESTONE

Milestone 5 — Breathing Mechanic

## STATUS

Milestone 0 — COMPLETED
Milestone 1 — COMPLETED
Milestone 2 — COMPLETED
Milestone 3 — COMPLETED (state layer only — see ROADMAP.md note)
Milestone 4 — COMPLETED
Milestone 5 — PARTIALLY COMPLETED (logic done and tested; touch feel unverified)

## BRANCH

`main`

## LATEST STABLE COMMIT

`a8122c5` — "feat: add BreathingController (Milestone 5, partial)"

## COMPLETED

- Environment/repo bootstrap, Godot pipeline validation, `GameState`
  singleton, `Player` controller (Milestones 0-4 — see ROADMAP.md and
  earlier CHANGELOG entries for detail).
- **`BreathingController`** (`scripts/player/breathing_controller.gd`,
  extends `Node`):
  - `is_holding: bool` + `set_holding(value)` — the input-facing entry
    point. Tests call this directly; real touch/mouse events will call it
    via `_unhandled_input` once wired into a live scene.
  - `compute_velocity_y(current_velocity_y, delta)` — pure physics.
    Accelerates toward `-max_rise_speed` (up) while holding or
    `+max_fall_speed` (down) while released, using `move_toward()` so it
    ramps smoothly and clamps without overshoot instead of snapping
    instantly to max speed.
  - `_unhandled_input()` — thin glue translating `InputEventScreenTouch`
    and left-click `InputEventMouseButton` into `set_holding()` calls.
  - Deliberately **not** wired to `Player` or any scene yet - that
    integration point belongs to whichever milestone builds the first
    real playable scene (Milestone 6 onward).
- `tests/test_breathing_controller.gd`: default state, released/holding
  acceleration direction and clamping, and rapid hold/release direction
  reversal (responsiveness) — 8/8 assertions pass.

## TESTED

- All prior headless checks still pass (`GameState`, `Player`).
- `tests/test_breathing_controller.gd` via `godot4 --headless -s`: 8/8
  passed.
- `scripts_dev/validate.sh`, `test.sh` (now runs 3 test files: state,
  player, breathing controller), `build.sh` — all pass end-to-end.

## NOT TESTED

- Godot Editor GUI (deferred to PC).
- Android SDK / export template setup.
- **Touch/mouse responsiveness and feel** — `_unhandled_input` glue code
  has never received a real input event; only the pure functions it calls
  are unit tested. This needs a live scene with a Player + BreathingController
  wired together (Milestone 6+) before it can even be manually tested,
  and then genuine on-device testing after that.
- Whether the current tuning (900 px/s² acceleration, 260 px/s max
  rise/fall speed, on a 1280px portrait viewport) feels good — placeholder
  numbers, expected to need adjustment once actually playable.

## KNOWN ISSUES

- RAM is tight on this device (~700 MiB "available" observed during
  discovery). Avoid heavy concurrent processes when running Godot.

## BLOCKERS

None for continuing code-first development. Android export tooling remains
an open question (see `docs/android_build.md`). Manual Android testing of
breathing *feel* is blocked until a playable scene exists (Milestone 6+),
not blocked by anything in this milestone itself.

## NEXT ACTION

Begin Milestone 6 (World Movement and Camera): scrolling/endless world
illusion and a camera following the player. This is also the natural point
to wire `Player` + `BreathingController` together in an actual scene for
the first time, which unblocks manual Android testing of Milestone 5's
touch feel.

## NEXT ENVIRONMENT

`[UBUNTU-CLI]` (logic/wiring), `[MANUAL-ANDROID]` soon after (breathing feel)
