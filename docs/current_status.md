# Current Status

_Last updated: 2026-07-26_

## CURRENT MILESTONE

Milestone 8 — Static and Moving Obstacles

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

## BRANCH

`main`

## LATEST STABLE COMMIT

(pending — this session's commit not yet made at time of writing; see
`git log` for the actual latest hash)

## COMPLETED

- Milestones 0-7: see ROADMAP.md and earlier CHANGELOG entries.
- **Milestone 8 — real obstacles, wired into the collision rule:**
  - `Obstacle` (`scripts/world/obstacle.gd` + `obstacle.tscn`): the static
    type. Just `radius` (exported, default 24.0) and a scene position - no
    movement script, no `Area2D`/`CollisionShape2D` (Milestone 7 already
    decided collision is pure geometry, not physics-engine overlap).
  - `MovingObstacle` (`scripts/world/moving_obstacle.gd` +
    `moving_obstacle.tscn`, extends `obstacle.gd` via file-path `extends`):
    the moving type. Vertical sine oscillation around an explicit
    `origin_y`, via pure `compute_offset_y(elapsed_time)` and
    `advance(delta)`. `origin_y`/`amplitude`/`period` are all exported.
  - `player.gd`: added exported `radius = 16.0` (matches its
    `CollisionShape2D`), so `Player` exposes the same position+radius
    contract `Obstacle` does.
  - `world.gd`: `gather_obstacles()` collects direct children that are
    `Obstacle` instances into `{"position", "radius"}` dictionaries.
    `get_game_state()` looks up the real `GameState` autoload via
    `get_node_or_null("/root/GameState")`, guarded by `is_inside_tree()` so
    it's a quiet no-op outside a live tree instead of an error. `step()`
    calls `CollisionSystem.check_obstacles()` whenever a real game_state is
    found.
  - `world.tscn`: added one `Obstacle` (700, 550) and one `MovingObstacle`
    (1100, 640; amplitude 150, period 3s) instance.
  - **Key discovery**: bare autoload identifiers (e.g. writing `GameState`
    directly in code) fail to *compile*, not just fail at runtime, when a
    script is loaded via `godot4 --headless -s <script>` - confirmed with a
    direct probe script. Autoloads only get injected as globals during a
    real project boot (main_scene load). This is why `world.gd` uses
    `get_node_or_null("/root/GameState")` (a runtime string lookup) instead
    of the bare identifier - it compiles everywhere and simply returns null
    when there's no live autoload to find.

## TESTED

- `tests/test_obstacle.gd` (5/5): scene instantiation, default/overridable
  radius, static (no movement).
- `tests/test_moving_obstacle.gd` (8/8): scene instantiation and
  inheritance from `Obstacle`, sine-offset math at quarter/half/
  three-quarter period, `advance()` applying it to `position.y` correctly
  over multiple calls.
- `tests/test_world.gd` extended (12/12, was 6/6): `gather_obstacles()`
  returns exactly the 2 real obstacles (not `Player`, not the 4 cosmetic
  Markers) with correct position/radius; `get_game_state()` is null under
  `-s` test mode; `step()` doesn't crash when it is.
- All previous tests still pass unchanged - 65 total assertions across 7
  test files.
- `scripts_dev/validate.sh`'s real project-boot check now exercises the
  actual `GameState` autoload path through `World.step()` for the first
  time, with zero errors (no death triggers during this smoke check since
  `GameState` starts at `MENU`, not `PLAYING` - nothing sets it to
  `PLAYING` anywhere yet, that's Milestone 11).

## NOT TESTED

- Godot Editor GUI (deferred to PC).
- Android SDK / export template setup.
- **A real collision actually happening on screen** - `GameState` is never
  transitioned to `PLAYING` yet (Milestone 11), so the death trigger has
  never fired outside `tests/test_collision_system.gd`'s isolated
  `GameState` instance.
- Visual/feel verification carried over from Milestones 5-6-8 (scrolling
  illusion, camera smoothing, touch responsiveness, obstacle appearance,
  oscillation feel) - still outstanding, still requires
  `[MANUAL-ANDROID]` or `[PC-GODOT]`.

## KNOWN ISSUES

- RAM is tight on this device (~700 MiB "available" observed during
  discovery). Avoid heavy concurrent processes when running Godot.
- Visual/feel checks for Milestones 5, 6, and 8 remain overdue - not a
  blocker for continued logic-first progress, but shouldn't be deferred
  indefinitely. Getting real eyes on a running session is worth doing soon.

## BLOCKERS

None for continuing code-first development. Android export tooling remains
an open question (see `docs/android_build.md`).

## NEXT ACTION

Begin Milestone 9 (Endless Mode and Difficulty): procedural obstacle
spawning (using `Obstacle`/`MovingObstacle` from this milestone) and a
difficulty curve tied to `ScrollManager.distance_traveled`. This will also
be the natural point to finally see obstacles actually appear and disappear
during a run, rather than the 2 fixed instances placed by hand in
`world.tscn`.

## NEXT ENVIRONMENT

`[UBUNTU-CLI]` (spawning/difficulty logic), `[MANUAL-ANDROID]` / `[PC-GODOT]`
still owed for Milestones 5, 6, 8 feel verification
