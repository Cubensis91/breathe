# Changelog

All notable changes to this project are documented here.

## [Unreleased]

### Added
- `DifficultyCurve` (`scripts/world/difficulty_curve.gd`): pure linear
  scroll-speed ramp capped at `max_speed`, now driving `ScrollManager`
  (`scroll_speed` is no longer constant - it increases with
  `distance_traveled`).
- `ObstacleSpawner` (`scripts/world/obstacle_spawner.gd`): pure spawn-timing
  rule (`should_spawn`/`compute_interval`) with spacing that tightens as
  distance grows. `world.gd` uses it to procedurally spawn random
  `Obstacle`/`MovingObstacle` instances ahead of the player and despawn
  ones that fall behind, replacing Milestone 8's 2 hand-placed obstacles
  entirely - `world.tscn` now starts with none.
  `tests/test_difficulty_curve.gd` (5/5), `tests/test_obstacle_spawner.gd`
  (9/9), `tests/test_scroll_manager.gd` (7/7, new dedicated coverage), and
  an extended `tests/test_world.gd` (15/15, was 12/12) cover the new logic
  and its bounded-growth behavior over a long simulated run. Visual/feel
  of spawning, scrolling, and the difficulty ramp is **not yet verified**.
- `Obstacle` (`scripts/world/obstacle.gd`, the static obstacle type) and
  `MovingObstacle` (`scripts/world/moving_obstacle.gd`, vertical sine
  oscillation around an explicit `origin_y`), with placeholder
  `Polygon2D` visuals. `Player` gained an exported `radius` matching its
  `CollisionShape2D`. `World.gather_obstacles()` collects real obstacle
  children; `World.get_game_state()` looks up the real `GameState`
  autoload via `get_node_or_null("/root/GameState")` (bare autoload
  identifiers fail to compile under `-s` script mode - discovered by
  direct probe) and wires it into `CollisionSystem.check_obstacles()`.
  `world.tscn` now has one of each obstacle type. Tests:
  `tests/test_obstacle.gd` (5/5), `tests/test_moving_obstacle.gd` (8/8),
  extended `tests/test_world.gd` (12/12, was 6/6). Visual/feel of the
  obstacles is **not yet verified**.
- `CollisionSystem` (`scripts/systems/collision_system.gd`): pure
  `circles_overlap()` geometry plus `check_obstacles()`, which triggers a
  `game_state.transition_to(DEAD)` when an obstacle overlaps the player
  while playing. Obstacles are plain `Dictionary`s (`position`, `radius`)
  since Milestone 8 hasn't created real obstacle nodes yet - wiring this
  into the actual `Player`/`World` physics loop is that milestone's job.
  `tests/test_collision_system.gd` covers geometry and death-trigger
  orchestration end to end (8/8 assertions) without needing a live scene
  tree or physics frames.
- `ScrollManager` (`scripts/world/scroll_manager.gd`): constant forward
  scroll speed + accumulating distance traveled, feeding the endless-world
  illusion (and later difficulty/scoring milestones).
- `World` (`scripts/world/world.gd`, `scripts/world/world.tscn`): the first
  real gameplay scene. Ties `Player` + `BreathingController` together with
  constant forward motion; includes static placeholder markers as a visual
  scroll reference. `project.godot` `run/main_scene` now points here
  (replacing Milestone 2's now-deleted `bootstrap.tscn`).
- Camera-follow via scene composition: `Camera2D` added as a child of
  `Player` in `player.tscn` with `position_smoothing_enabled` - no custom
  script needed.
- `player.gd`: `integrate_physics()` now drives `velocity.y` from a child
  `BreathingController` if one exists (looked up lazily, not cached), so
  `Player` still works identically in isolation (no children, existing
  tests) and fully wired (scene instance).
- `tests/test_world.gd` (6/6 assertions); `tests/test_player.gd` extended
  to cover the scene's `BreathingController` wiring (9/9 assertions).
  Touch/visual feel for the scrolling world and camera-follow is **not yet
  verified** - requires manual Android/PC testing.
- `BreathingController` (`scripts/player/breathing_controller.gd`): hold →
  inhale → rise / release → exhale → descend, via a pure
  `compute_velocity_y()` function (ramped acceleration using `move_toward`,
  clamped at `max_rise_speed`/`max_fall_speed`) plus thin `_unhandled_input`
  glue for touch/mouse. Decoupled from `Player` - not yet wired into a
  scene. `tests/test_breathing_controller.gd` covers the physics math
  (8/8 assertions pass). Touch feel is **not yet verified** - requires
  manual Android testing once wired into an actual playable scene.
- `Player` controller (`scripts/player/player.gd`, `Area2D`) with
  position/velocity state and generic `integrate_physics(delta)`
  integration, decoupled from whatever will drive velocity (breathing
  input, Milestone 5). `scripts/player/player.tscn` adds a circle
  `CollisionShape2D` and a placeholder `Polygon2D` visual.
  `tests/test_player.gd` covers scene instantiation and integration math
  (6/6 assertions pass).
- `GameState` core singleton (`scripts/core/game_state.gd`, autoloaded):
  MENU/PLAYING/DEAD state machine with an explicit legal-transition table
  and a `state_changed` signal.
- Headless GDScript test convention (`tests/test_*.gd` via
  `godot4 --headless -s`); `tests/test_game_state.gd` covering the state
  machine's transition rules.
- `scripts_dev/test.sh` now runs the GDScript test suite instead of only
  doing a boot check.
- Initial repository bootstrap: directory structure, documentation set
  (README, CONTRIBUTING, ROADMAP, ARCHITECTURE, docs/).
- Environment discovery documented in `docs/setup.md`.
- Verified Godot 4.7.1 headless execution on-device (aarch64 Ubuntu
  proot-distro under Termux).
- Minimal Godot 4 project created for pipeline validation (Milestone 2).
- `scripts_dev/` automation scaffolding (`validate.sh`, `test.sh`,
  `build.sh`, `export_android.sh`).
