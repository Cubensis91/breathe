# Current Status

_Last updated: 2026-07-26_

## CURRENT MILESTONE

Milestone 7 — Collision System

## STATUS

Milestone 0 — COMPLETED
Milestone 1 — COMPLETED
Milestone 2 — COMPLETED (superseded: `bootstrap.tscn` deleted, `world.tscn`
is now `main_scene`)
Milestone 3 — COMPLETED (state layer only — see ROADMAP.md note)
Milestone 4 — COMPLETED
Milestone 5 — PARTIALLY COMPLETED (logic done and tested; touch feel unverified)
Milestone 6 — PARTIALLY COMPLETED (logic/wiring done and tested; visual feel unverified)
Milestone 7 — COMPLETED (rule) — runtime wiring deferred to Milestone 8

## BRANCH

`main`

## LATEST STABLE COMMIT

`be08c1b` — "feat: add CollisionSystem (Milestone 7, rule only)"

## COMPLETED

- Milestones 0-6: see ROADMAP.md and earlier CHANGELOG entries.
- **Milestone 7 — collision rule:**
  - `CollisionSystem` (`scripts/systems/collision_system.gd`, `RefCounted`,
    static methods): `circles_overlap(pos_a, radius_a, pos_b, radius_b)`
    is pure circle-circle overlap geometry. `check_obstacles(player_position,
    player_radius, obstacles, game_state)` checks a list of obstacles
    (plain `Dictionary`s with `"position"`/`"radius"`) against the player
    and triggers `game_state.transition_to(game_state.State.DEAD)` if
    anything overlaps while `is_playing()`. Returns whether it triggered.
  - `game_state` is an explicit parameter, not the `GameState` autoload -
    matches the isolated-instance testing pattern already used for
    `GameState` itself, and keeps this system testable without any
    project-wide state.
  - Deliberately **not wired** into `Player`/`World`'s actual physics loop
    yet: there are no real obstacle nodes to check against (Milestone 8).
    Obstacles are plain Dictionaries here specifically so this milestone
    doesn't have to guess at Milestone 8's actual node/scene design.

## TESTED

- `tests/test_collision_system.gd` (8/8): overlapping/non-overlapping/
  exactly-touching circle geometry; death triggers only on overlap while
  playing; no-op once no longer playing (doesn't re-trigger or error after
  death).
- All previous tests still pass unchanged (`test_game_state.gd` 15/15,
  `test_player.gd` 9/9, `test_breathing_controller.gd` 8/8, `test_world.gd`
  6/6) - 46 total assertions across 5 test files.
- `scripts_dev/validate.sh`, `test.sh`, `build.sh` all pass.

## NOT TESTED

- Godot Editor GUI (deferred to PC).
- Android SDK / export template setup.
- Real obstacle-vs-player collision at runtime (no obstacle nodes exist
  yet - Milestone 8).
- Visual/feel verification carried over from Milestones 5-6 (scrolling
  illusion, camera smoothing, touch responsiveness) - still outstanding,
  still requires `[MANUAL-ANDROID]` or `[PC-GODOT]`.

## KNOWN ISSUES

- RAM is tight on this device (~700 MiB "available" observed during
  discovery). Avoid heavy concurrent processes when running Godot.
- Visual/feel checks for Milestones 5 and 6 remain overdue - not a
  blocker for continued logic-first progress, but shouldn't be deferred
  indefinitely.

## BLOCKERS

None for continuing code-first development. Android export tooling remains
an open question (see `docs/android_build.md`).

## NEXT ACTION

Begin Milestone 8 (Static and Moving Obstacles): create real obstacle
scenes (one static, one moving type), and this is the point to actually
wire `CollisionSystem.check_obstacles()` into `World`'s physics loop against
real obstacle instances - reading their actual position/radius each frame
instead of the Dictionary stand-ins used for Milestone 7's tests.

## NEXT ENVIRONMENT

`[UBUNTU-CLI]` (obstacle logic + wiring), `[MANUAL-ANDROID]` / `[PC-GODOT]`
still owed for Milestones 5-6 feel verification
