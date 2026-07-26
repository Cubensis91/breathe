# Changelog

All notable changes to this project are documented here.

## [Unreleased]

### Added
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
