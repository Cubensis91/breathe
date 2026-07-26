# Current Status

_Last updated: 2026-07-26_

## CURRENT MILESTONE

Milestone 4 — Player Controller

## STATUS

Milestone 0 — COMPLETED
Milestone 1 — COMPLETED
Milestone 2 — COMPLETED
Milestone 3 — COMPLETED (state layer only — see ROADMAP.md note)
Milestone 4 — COMPLETED

## BRANCH

`main`

## LATEST STABLE COMMIT

(pending — this session's commit not yet made at time of writing; see
`git log` for the actual latest hash)

## COMPLETED

- Environment discovery, GitHub repo, directory structure, docs,
  `scripts_dev/*.sh` automation (Milestones 0-1).
- Godot 4.7.1-stable installed and verified headless on-device; minimal
  project boots cleanly (Milestone 2).
- `GameState` core singleton: MENU/PLAYING/DEAD state machine with legal-
  transition table and `state_changed` signal (Milestone 3).
- **`Player` controller** (`scripts/player/player.gd`, extends `Area2D`):
  `velocity: Vector2` state and `integrate_physics(delta)` which does
  `position += velocity * delta`. Nothing yet decides what velocity should
  be - that's explicitly Milestone 5's job (breathing input). `_physics_process`
  calls `integrate_physics` automatically when the node is in a live tree.
- `scripts/player/player.tscn`: `Area2D` root, circular `CollisionShape2D`
  (radius 16, ready for Milestone 7 collision work), and a `Polygon2D`
  placeholder visual (flat teal square) that can be swapped for real art
  later without touching `player.gd`.
- `tests/test_player.gd`: verifies the scene instantiates as an `Area2D`
  with zero starting velocity, and that `integrate_physics()` produces
  correct position deltas across multiple calls with different
  velocities/deltas (6/6 assertions pass).

## TESTED

- `godot4 --headless --version`, project boot, `GameState` autoload wiring
  (Milestones 0-3, see prior status entries / CHANGELOG).
- `tests/test_player.gd` via `godot4 --headless -s`: 6/6 passed, clean exit,
  no leaked instances.
- `scripts_dev/validate.sh`, `test.sh` (now runs both `test_game_state.gd`
  and `test_player.gd`), `build.sh` — all pass end-to-end.

## NOT TESTED

- Godot Editor GUI (deferred to PC).
- Android SDK / export template setup.
- Player movement *feel* - there's no input driving velocity yet, so
  nothing to manually test on-device until Milestone 5.
- Visual appearance of the placeholder shape in an actual running window
  (headless-only verification so far; expected to look right once opened
  in the Editor or on-device, but not visually confirmed).

## KNOWN ISSUES

- RAM is tight on this device (~700 MiB "available" observed during
  discovery). Avoid heavy concurrent processes when running Godot.

## BLOCKERS

None. Android export tooling remains an open question (see
`docs/android_build.md`) but doesn't block continued code-first work.

## NEXT ACTION

Begin Milestone 5 (Breathing Mechanic): hold → inhale → rise, release →
exhale → descend, as an input/physics module that sets `Player.velocity`.
Headlessly testable for the velocity math given simulated hold/release
input; touch responsiveness and feel require manual Android testing after.

## NEXT ENVIRONMENT

`[UBUNTU-CLI]` (logic), `[MANUAL-ANDROID]` later (feel)
