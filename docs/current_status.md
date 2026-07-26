# Current Status

_Last updated: 2026-07-26_

## CURRENT MILESTONE

Milestone 6 — World Movement and Camera

## STATUS

Milestone 0 — COMPLETED
Milestone 1 — COMPLETED
Milestone 2 — COMPLETED (superseded: `bootstrap.tscn` deleted, `world.tscn`
is now `main_scene` and does the same "boots headlessly" job, plus more)
Milestone 3 — COMPLETED (state layer only — see ROADMAP.md note)
Milestone 4 — COMPLETED
Milestone 5 — PARTIALLY COMPLETED (logic done and tested; touch feel unverified)
Milestone 6 — PARTIALLY COMPLETED (logic/wiring done and tested; visual feel unverified)

## BRANCH

`main`

## LATEST STABLE COMMIT

(pending — this session's commit not yet made at time of writing; see
`git log` for the actual latest hash)

## COMPLETED

- Milestones 0-5: see ROADMAP.md and earlier CHANGELOG entries.
- **Milestone 6 — first real gameplay scene:**
  - `ScrollManager` (`scripts/world/scroll_manager.gd`): constant
    `scroll_speed` + accumulating `distance_traveled` via `advance(delta)`.
  - `World` (`scripts/world/world.gd` + `world.tscn`): instances `Player`,
    owns a `ScrollManager`, and on each `step(delta)` sets
    `player.velocity.x = scroll_manager.scroll_speed` - constant forward
    motion driving the endless-world illusion. Includes 4 static
    `Polygon2D` markers at fixed world-space X positions as a placeholder
    visual reference for scrolling (swappable later, no gameplay code
    depends on them).
  - **Camera-follow needed zero new code**: `Camera2D` is now a child of
    `Player` in `player.tscn`, with `position_smoothing_enabled = true`.
    Normal Godot parent/child transform inheritance does the "follow" job.
  - `player.gd` updated: `integrate_physics()` looks up a sibling
    `BreathingController` child via `get_node_or_null()` (lazy, not
    `@onready`-cached) and uses it to drive `velocity.y` when present.
    Verified this doesn't change behavior for a bare `Player` with no
    children (existing isolated tests still pass unmodified in outcome).
  - `project.godot`: `run/main_scene` now points at
    `res://scripts/world/world.tscn`. Deleted
    `scripts/core/bootstrap.gd`/`.tscn` (Milestone 2's pipeline-validation
    stub) since booting the real gameplay scene headlessly is a strictly
    stronger version of the same check.
  - Cross-file GDScript typing gotcha discovered and fixed: `class_name`
    declarations only become globally resolvable after a project scan
    (normally done by the Editor), which has never happened here since
    this project has only ever been touched via CLI. Fixed by using
    explicit `preload()` consts for cross-file type references (e.g.
    `const PlayerScript = preload("res://scripts/player/player.gd")`)
    instead of relying on bare `Player`/`BreathingController`/`ScrollManager`
    type names resolving globally. `class_name` declarations are kept (they
    work fine once a PC/Editor session eventually scans the project) but
    nothing here depends on that having happened.

## TESTED

- `tests/test_world.gd` (6/6): scene instantiation, `World` finding its
  `Player` child, `player.velocity.x`/`position.x` and
  `scroll_manager.distance_traveled` tracking correctly across multiple
  manually-driven physics steps.
- `tests/test_player.gd` (9/9, was 6/6): added coverage for the scene
  instance finding its `BreathingController` child and holding driving it
  upward, plus confirming a bare `Player` has no `BreathingController`.
- All previous tests (`test_game_state.gd` 15/15, `test_breathing_controller.gd`
  8/8) still pass unchanged.
- `scripts_dev/validate.sh`, `test.sh` (4 test files, 38 total assertions),
  `build.sh` all pass with `world.tscn` as the booted main scene.

## NOT TESTED

- Godot Editor GUI (deferred to PC).
- Android SDK / export template setup.
- **Visual/feel verification of anything in this milestone**: does the
  scrolling illusion actually read as scrolling, does the camera-follow
  smoothing feel right, is touch responsiveness (Milestone 5) good now
  that it's wired into a real scene. All require `[MANUAL-ANDROID]` or
  `[PC-GODOT]`.
- Current tuning (200 px/s scroll speed, 900 px/s² breathing acceleration,
  260 px/s max rise/fall) is all placeholder - expected to need adjustment
  once actually playable.

## KNOWN ISSUES

- RAM is tight on this device (~700 MiB "available" observed during
  discovery). Avoid heavy concurrent processes when running Godot.
- Node processing order (World's `_physics_process` setting
  `player.velocity.x` vs. Player's `_physics_process` consuming it in the
  same frame) relies on Godot's default parent-before-child processing
  order. Not explicitly enforced with `process_priority` - if it were ever
  reversed, the practical effect is a harmless one-frame lag, not a
  correctness bug, so this wasn't treated as blocking.

## BLOCKERS

None for continuing code-first development. Android export tooling remains
an open question (see `docs/android_build.md`). Manual Android/PC testing
of visual feel (Milestones 5 & 6) is now unblocked in principle (there's a
real scene to look at) but hasn't happened yet - it's the natural next
checkpoint once code-first progress reaches a good pausing point.

## NEXT ACTION

Begin Milestone 7 (Collision System): overlap detection between `Player`
and obstacles, triggering a death transition via `GameState`. Also a good
moment to actually open `world.tscn` on a PC (or run the APK on Android,
once export tooling is sorted) to manually verify Milestones 5-6 feel
reasonable before building more on top.

## NEXT ENVIRONMENT

`[UBUNTU-CLI]` (collision logic), `[MANUAL-ANDROID]` / `[PC-GODOT]`
(overdue visual/feel check)
