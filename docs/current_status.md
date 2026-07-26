# Current Status

_Last updated: 2026-07-26_

## CURRENT MILESTONE

Milestone 9 — Endless Mode and Difficulty

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

## BRANCH

`main`

## LATEST STABLE COMMIT

`ab7e325` — "feat: add procedural obstacle spawning and difficulty ramp (Milestone 9)"

## COMPLETED

- Milestones 0-8: see ROADMAP.md and earlier CHANGELOG entries.
- **Milestone 9 — endless spawning and difficulty:**
  - `DifficultyCurve` (`scripts/world/difficulty_curve.gd`): pure
    `compute_scroll_speed(distance_traveled)`, linear ramp from
    `base_speed` (200) capped at `max_speed` (500).
  - `ScrollManager` updated: `scroll_speed` is no longer constant -
    `advance(delta)` recomputes it from the new `distance_traveled` via an
    owned `DifficultyCurve`, after using the *current* speed to advance
    distance (same order as `Player.integrate_physics`'s velocity handling).
  - `ObstacleSpawner` (`scripts/world/obstacle_spawner.gd`): pure
    `should_spawn(distance_traveled)` / `compute_interval(distance_traveled)`
    - spawn spacing tightens toward `min_interval` as distance grows.
    Decoupled from Godot entirely; deciding what/where to spawn is
    `world.gd`'s job.
  - `world.gd`: `_spawn_obstacle()` instances a random `Obstacle` or
    `MovingObstacle` ahead of the player (900px lookahead, randomized Y)
    each time `spawner.should_spawn()` fires. `_despawn_old_obstacles()`
    frees anything more than 300px behind the player, keeping the run
    bounded rather than growing the scene tree forever.
  - `world.tscn`: removed the 2 hand-placed obstacles from Milestone 8 -
    spawning is now fully procedural, starting from zero.

## TESTED

- `tests/test_difficulty_curve.gd` (5/5): ramp correctness, cap behavior,
  monotonicity.
- `tests/test_scroll_manager.gd` (7/7, new): self-consistency between
  `scroll_speed` and the difficulty curve across many steps, cap respected.
- `tests/test_obstacle_spawner.gd` (9/9): threshold timing, interval
  shrink/clamp behavior.
- `tests/test_world.gd` (15/15, was 12/12): starts with zero obstacles;
  spawns at least one after enough distance; stays bounded (not unbounded
  growth) over a long simulated run (65 fast-forwarded seconds); other
  Milestone 6-8 coverage retained.
- All previous tests still pass unchanged - 89 total assertions across 10
  test files.
- `scripts_dev/validate.sh`, `test.sh`, `build.sh` all pass, including the
  real project-boot check.

## NOT TESTED

- Godot Editor GUI (deferred to PC).
- Android SDK / export template setup.
- **Visual/feel of anything in this milestone**: does the difficulty ramp
  feel fair, do obstacles read clearly as they scroll in/out, does the
  spawn/despawn cadence look reasonable on screen. Same carried-over debt
  as Milestones 5, 6, 8 - still requires `[MANUAL-ANDROID]` or `[PC-GODOT]`.
- Real collision with a *procedurally spawned* obstacle - `GameState` still
  never reaches `PLAYING` (Milestone 11), so death-on-collision has still
  only ever been exercised via `tests/test_collision_system.gd`'s isolated
  instance.

## KNOWN ISSUES

- RAM is tight on this device (~700 MiB "available" observed during
  discovery). Avoid heavy concurrent processes when running Godot.
- Visual/feel checks for Milestones 5, 6, 8, and now 9 remain overdue -
  not a blocker for continued logic-first progress, but this backlog is
  growing and shouldn't be deferred indefinitely. Worth a dedicated PC/
  Android session soon.

## BLOCKERS

None for continuing code-first development. Android export tooling remains
an open question (see `docs/android_build.md`).

## NEXT ACTION

Begin Milestone 10 (Score and Persistence): distance/time-based score
(likely just `ScrollManager.distance_traveled`, already tracked) and local
high-score save/load. Also a good moment to consider finally doing the
overdue visual/feel pass across Milestones 5, 6, 8, 9 before the backlog
grows further.

## NEXT ENVIRONMENT

`[UBUNTU-CLI]` (scoring/persistence logic), `[MANUAL-ANDROID]` / `[PC-GODOT]`
increasingly overdue for Milestones 5, 6, 8, 9 feel verification
