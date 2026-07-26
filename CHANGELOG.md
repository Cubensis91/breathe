# Changelog

All notable changes to this project are documented here.

## [Unreleased]

### Added
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
