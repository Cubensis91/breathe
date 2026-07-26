# Changelog

All notable changes to this project are documented here.

## [Unreleased]

### Added
- Audio system (Milestone 12): `AudioSettings` (on/off, `FileAccess`-backed,
  same pattern as `HighScorePersistence`) and `AudioController`
  (`scripts/audio/audio_controller.gd` + `audio_controller.tscn`, 4
  stream-less `AudioStreamPlayer` children - no real audio assets exist
  yet, adding them later is an asset-only change). `BreathingController`
  gained an `inhale_started` signal (fires exactly on hold-start).
  `world.gd` wires it all together: inhale on hold-start, collision/
  game-over sounds on death, music start on entering `PLAYING`.
  `tests/test_audio_settings.gd` (7/7), `tests/test_audio_controller.gd`
  (12/12), and extended `tests/test_breathing_controller.gd` (12/12, was
  8/8) cover the routing/settings logic. No audible sound exists to verify
  yet - a genuine content gap, not a deferred check.
- Full `GameState` wiring (Milestone 11): `world.gd`'s `step()` freezes
  unless `GameState.is_playing()`; `reset_session()` resets score,
  obstacles, and player position/velocity/breathing state whenever a
  transition into `PLAYING` happens (connected lazily on first `step()`,
  not `_ready()`); tapping while not playing starts or restarts a run via
  the already-legal `MENU`/`DEAD` -> `PLAYING` transitions
  (`is_tap_event()` extracted as a pure, testable function).
  `breathing_controller.gd` now ignores input unless playing.
- `Hud` (`scripts/ui/hud.gd`, `hud.tscn`, `CanvasLayer`): minimal UI - a
  menu prompt, live score while playing, or a death summary + restart
  prompt, via a pure `compute_display_text()`. Added as a child of `World`.
- Extended `tests/test_world.gd` (27/27, was 15/15) and new
  `tests/test_hud.gd` (8/8). Discovered and documented a hard limitation:
  `-s` script mode's own `SceneTree.root` can't resolve absolute
  (`/root/...`) NodePaths, so the autoload-gated code paths (freeze
  check, tap-to-start) can only be exercised by a real project boot -
  confirmed by direct probe, not just assumed. `reset_session()` and
  `_on_game_state_changed()` don't have that dependency and are tested
  directly. Full-flow and UI visual/feel verification remain outstanding.
- `Score` (`scripts/systems/score.gd`): pure `compute(distance_traveled)`
  converting distance into a display score, one source of truth for the
  scale factor.
- `HighScorePersistence` (`scripts/systems/high_score.gd`): local
  high-score save/load via `FileAccess`, with a `record_score()` rule that
  saves only strictly-greater scores. `world.gd` records a score exactly
  once per run, right when `CollisionSystem.check_obstacles()` reports
  death was triggered that frame. `tests/test_score.gd` (4/4) and
  `tests/test_high_score.gd` (10/10, using a throwaway per-run save path,
  cleaned up afterward) cover the new logic.
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
