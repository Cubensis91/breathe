# Current Status

_Last updated: 2026-07-26_

## CURRENT MILESTONE

Milestone 3 — Core Architecture (state layer)

## STATUS

Milestone 0 — COMPLETED
Milestone 1 — COMPLETED
Milestone 2 — COMPLETED
Milestone 3 — COMPLETED (state layer only — see note below)

## BRANCH

`main`

## LATEST STABLE COMMIT

(pending — this session's commit not yet made at time of writing; see
`git log` for the actual latest hash)

## COMPLETED

- Environment discovery performed and documented (`docs/setup.md`).
- GitHub repository created: https://github.com/Cubensis91/breathe (public).
- Directory structure, full documentation set, `scripts_dev/*.sh` automation.
- Godot 4.7.1-stable installed and verified headless on-device.
- Minimal Godot project (`scripts/core/bootstrap.gd` + `.tscn`) boots
  headlessly without error.
- **`GameState` core singleton** (`scripts/core/game_state.gd`), autoloaded
  in `project.godot`: `State` enum (MENU/PLAYING/DEAD), `transition_to()`
  with an explicit legal-transition table (MENU→PLAYING, PLAYING→DEAD,
  DEAD→PLAYING, DEAD→MENU; anything else is rejected and logged), and a
  `state_changed(previous, current)` signal. `bootstrap.gd` asserts the
  autoload defaults to MENU on boot as a smoke test.
- Headless GDScript test convention established: `tests/test_*.gd` scripts
  extend `SceneTree`, run assertions in `_initialize()`, `quit(0)`/`quit(1)`.
  `tests/test_game_state.gd` covers default state, legal/illegal/no-op
  transitions, and signal emission (15/15 assertions pass).
- `scripts_dev/test.sh` now actually runs `tests/test_*.gd` via
  `godot4 --headless -s` and fails the build if any test file exits non-zero
  (previously it only did a boot check).

**Note on scope:** Milestone 3's objective lists input/physics/state/world/
UI/audio/persistence layers. Only the **state** layer has real content so
far (`GameState`). The others are deliberately not stubbed out yet — empty
placeholder scripts with no logic would violate the project's
no-premature-abstraction rule. They'll be created in their own milestones
(4 - Player, 5 - Breathing/input+physics, 6 - World, 7/8 - Collision/
Obstacles, 10 - Persistence, 11 - UI, 12 - Audio) when there's actual
behavior to put in them.

## TESTED

- `godot4 --headless --version`, `gh auth status`, `git --version`,
  `gh --version`.
- `godot4 --headless --path . --quit` boots the project, GameState autoload
  confirmed wired (prints `state=MENU`).
- `tests/test_game_state.gd` via `godot4 --headless -s`: 15/15 passed, no
  leaked ObjectDB instances (test frees its Node instances explicitly).
- `scripts_dev/validate.sh`, `test.sh`, `build.sh` all pass end-to-end.
  `scripts_dev/export_android.sh` still correctly fails with an actionable
  error (no export templates installed).

## NOT TESTED

- Godot Editor GUI (deferred to PC).
- Android SDK / export template setup.
- Any player/world/UI/audio code — none exists yet.

## KNOWN ISSUES

- RAM is tight on this device (~700 MiB "available" observed during
  discovery). Avoid heavy concurrent processes when running Godot.

## BLOCKERS

None. Android export tooling remains an open question (see
`docs/android_build.md`) but doesn't block continued code-first work.

## NEXT ACTION

Begin Milestone 4 (Player Controller): a player node with position/velocity
state and a placeholder visual shape, no real art yet. Keep it headlessly
testable where the logic is (position/velocity math), acknowledging that
feel/responsiveness needs manual Android testing later.

## NEXT ENVIRONMENT

`[UBUNTU-CLI]` (logic), `[MANUAL-ANDROID]` later (feel)
