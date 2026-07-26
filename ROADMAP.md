# ROADMAP

Milestones are implemented one at a time, smallest logical increment first.
A milestone is only marked **COMPLETED** when its acceptance criteria are
verified. If verification requires a PC or manual Android testing that
hasn't happened yet, it is marked **PARTIALLY COMPLETED**.

Environment tags: `[TERMUX]` `[UBUNTU-CLI]` `[GITHUB]` `[PC-GODOT]`
`[MANUAL-ANDROID]` `[HYBRID]`

---

## Milestone 0 — Environment and GitHub Validation
**Status: COMPLETED**

- Objective: Verify the Termux → Ubuntu (proot-distro) → Git → GitHub →
  Godot CLI pipeline actually works on this device before building anything.
- Acceptance criteria: Git/GitHub CLI authenticated; Godot 4.x binary runs
  headlessly; repo exists on GitHub with initial structure pushed.
- Dependencies: None.
- Can be done from Termux/Ubuntu: Yes — everything except APK install/run.
- Can be tested headlessly: Yes (`godot4 --headless --version`).
- Requires manual Android testing: No (yet).
- Requires PC: No.

## Milestone 1 — Repository Bootstrap
**Status: COMPLETED**

- Objective: Create `breathe` GitHub repo and initial directory/doc structure.
- Acceptance criteria: All top-level docs exist; folder structure exists;
  pushed to `main`.
- Dependencies: Milestone 0.
- Environment: `[UBUNTU-CLI]` `[GITHUB]`.

## Milestone 2 — Minimal Godot Project
**Status: COMPLETED**

- Objective: Smallest possible valid `project.godot` that boots and can be
  validated headlessly, proving the CLI pipeline before real gameplay work.
- Acceptance criteria: `godot4 --headless --quit` runs against the project
  without error.
- Dependencies: Milestone 0.
- Environment: `[UBUNTU-CLI]`. Headless testable: Yes. PC required: No.

## Milestone 3 — Core Architecture
**Status: COMPLETED (state layer) — other layers land in their own milestones**

- Objective: Establish the separation of game logic / input / physics /
  state / world / UI / audio / persistence described in ARCHITECTURE.md as
  plain GDScript classes, independent of scenes.
- What landed: `scripts/core/game_state.gd` — the `GameState` autoload
  singleton (MENU/PLAYING/DEAD enum, `transition_to()` with an explicit
  legal-transition table, `state_changed` signal). This is the one piece of
  core architecture with real behavior today; input/physics/world/UI/audio/
  persistence are intentionally left for Milestones 4-12, where they'll have
  actual logic to contain instead of empty placeholder files.
- Acceptance criteria: `GameState` autoload boots correctly (verified via
  `bootstrap.gd` asserting default state); headless test
  `tests/test_game_state.gd` covers default state, legal transitions,
  illegal-transition rejection, no-op transitions, and signal emission —
  15/15 assertions pass.
- Dependencies: Milestone 2.
- Environment: `[UBUNTU-CLI]`. Headless testable: Partially (structure and
  unit-testable logic, not rendering). PC required: No.

## Milestone 4 — Player Controller
**Status: COMPLETED**

- Objective: Player node with position/velocity state, no visuals required
  yet (placeholder shape).
- What landed: `scripts/player/player.gd` (`Player`, extends `Area2D`) with
  `velocity: Vector2` and `integrate_physics(delta)` (`position += velocity *
  delta`). Deliberately does not decide what drives velocity - that's
  Milestone 5 (breathing input). `scripts/player/player.tscn` wires it up
  with a `CollisionShape2D` (circle, for Milestone 7 collision) and a
  `Polygon2D` placeholder visual (a flat-colored square, swappable later
  without touching gameplay code).
- Acceptance criteria: `player.tscn` instantiates cleanly; default state is
  zero position/velocity; `integrate_physics()` correctly accumulates
  position across multiple calls with different velocities and deltas.
  `tests/test_player.gd`: 6/6 assertions pass.
- Dependencies: Milestone 3.
- Environment: `[UBUNTU-CLI]` for logic (done, headlessly tested).
  `[HYBRID]` for feel - not applicable yet since there's no input driving
  velocity until Milestone 5; manual Android testing becomes relevant then.

## Milestone 5 — Breathing Mechanic
**Status: PARTIALLY COMPLETED** — logic done and tested; touch feel unverified

- Objective: Hold → inhale → rise, release → exhale → descend, as a testable
  input/physics module.
- What landed: `scripts/player/breathing_controller.gd` (`BreathingController`,
  extends `Node`). `set_holding(bool)` is the input-facing entry point;
  `compute_velocity_y(current_velocity_y, delta)` is a pure physics function
  (uses `move_toward` to accelerate toward `-max_rise_speed` while holding or
  `+max_fall_speed` while released, so it ramps rather than snaps). A thin
  `_unhandled_input()` translates `InputEventScreenTouch`/left-click
  `InputEventMouseButton` into `set_holding()` calls. Deliberately does not
  reference `Player` or any scene - wiring it to an actual player in a live
  scene is a later milestone's job (world/gameplay scene, Milestone 6+).
- Acceptance criteria (logic): default `is_holding == false`; released
  state accelerates toward `+max_fall_speed` and clamps without overshoot;
  holding accelerates toward `-max_rise_speed` and clamps without overshoot;
  rapid hold/release immediately reverses acceleration direction.
  `tests/test_breathing_controller.gd`: 8/8 assertions pass.
- Acceptance criteria (feel): **not yet verified.** Touch responsiveness,
  whether the ramp (900 px/s² accel, 260 px/s cap on a 1280px-tall viewport)
  actually feels good, and rapid hold/release responsiveness on a real
  screen all require `[MANUAL-ANDROID]` testing this milestone doesn't
  include. The `_unhandled_input` touch/mouse glue itself is also untested
  beyond compiling - only the pure functions it calls are unit tested.
- Dependencies: Milestone 4.
- Environment: `[UBUNTU-CLI]`. Headless testable: movement math only (done).
  Manual Android test required: touch responsiveness and feel (not done).

## Milestone 6 — World Movement and Camera
**Status: PARTIALLY COMPLETED** — logic/wiring done and tested; visual feel unverified

- Objective: Scrolling/endless world illusion, camera following the player.
- What landed:
  - `scripts/world/scroll_manager.gd` (`ScrollManager`, `RefCounted`):
    `scroll_speed` + `distance_traveled`, `advance(delta)` pure arithmetic.
    Feeds Milestone 9 (difficulty) and Milestone 10 (scoring) later.
  - `scripts/world/world.gd` + `world.tscn` (`World`, `Node2D`): the first
    real gameplay scene. `step(delta)` advances `ScrollManager` and sets
    `player.velocity.x = scroll_manager.scroll_speed` (constant forward
    motion). Instances `player.tscn` as a child, plus four static
    `Polygon2D` markers at fixed world-space X positions purely so a human
    tester has something visible to confirm scrolling against (placeholder,
    swappable for real background art in Milestone 15).
  - **Camera-follow needed no new code**: `Camera2D` was added as a child
    of `Player` in `player.tscn` with `position_smoothing_enabled`, so it
    tracks the player's transform automatically via normal scene-tree
    parenting.
  - `player.gd` updated: `integrate_physics()` now looks up a
    `BreathingController` child (if present) via `get_node_or_null()` and
    uses `compute_velocity_y()` to drive `velocity.y`. Looked up lazily
    (not cached with `@onready`) so it behaves identically whether the
    node is bare, scene-instantiated, or added to a live tree - this is
    what makes it possible to keep testing `Player` in isolation (no
    children) alongside testing it fully wired (scene, with
    `BreathingController` + `Camera2D` children).
  - `project.godot`: `run/main_scene` now points at `world.tscn` (was the
    Milestone 2 `bootstrap.tscn`, which has been deleted - its only job,
    proving headless boot works, is now done more strongly by booting the
    real gameplay scene).
- Acceptance criteria (logic/wiring): `world.tscn` instantiates; `World`
  finds its `Player` child; after stepping, `player.velocity.x` tracks
  `scroll_speed` and `player.position.x` / `distance_traveled` advance
  correctly; `Player` scene instance finds its `BreathingController` child
  and holding drives it upward. `tests/test_world.gd` (6/6) and updated
  `tests/test_player.gd` (9/9) pass. Project boots headlessly with
  `world.tscn` as main scene.
- Acceptance criteria (visual/feel): **not yet verified.** Nobody has
  looked at this running - whether the markers actually read as "scrolling
  world," whether the camera-follow smoothing feels right, and touch
  responsiveness from Milestone 5 all require `[MANUAL-ANDROID]` or
  `[PC-GODOT]` testing this milestone doesn't include.
- Dependencies: Milestones 4, 5.
- Environment: `[HYBRID]`. Camera/world logic: `[UBUNTU-CLI]`, headlessly
  tested (done). Visual feel: `[MANUAL-ANDROID]` / `[PC-GODOT]` (not done).

## Milestone 7 — Collision System
**Status: NOT STARTED**

- Objective: Collision detection between player and obstacles, death trigger.
- Environment: `[UBUNTU-CLI]`. Headless testable: Yes (geometry/logic).

## Milestone 8 — Static and Moving Obstacles
**Status: NOT STARTED**

- Objective: One static obstacle type, one moving obstacle type.
- Environment: `[UBUNTU-CLI]` for logic, `[PC-GODOT]` for visual placement.

## Milestone 9 — Endless Mode and Difficulty
**Status: NOT STARTED**

- Objective: Procedural obstacle spawning, difficulty scaling over
  time/distance.
- Environment: `[UBUNTU-CLI]`. Headless testable: Yes (spawn/difficulty
  curves).

## Milestone 10 — Score and Persistence
**Status: NOT STARTED**

- Objective: Distance/time-based scoring, local high-score save/load.
- Environment: `[UBUNTU-CLI]`. Headless testable: Yes.

## Milestone 11 — UI and Game States
**Status: NOT STARTED**

- Objective: Menu / playing / dead / restart states, minimal UI.
- Environment: `[HYBRID]`. State machine logic headless-testable; UI layout
  benefits from `[PC-GODOT]`.

## Milestone 12 — Audio System
**Status: NOT STARTED**

- Objective: Inhale, collision, game-over sounds; one music loop; on/off
  setting.
- Environment: `[HYBRID]`. Audio routing logic testable headlessly; actual
  sound/feel requires manual Android test or PC.

## Milestone 13 — Automated Validation and Testing
**Status: NOT STARTED**

- Objective: Consolidate headless test suite covering state transitions,
  scoring, movement, collision, difficulty, spawning, persistence, config.
- Environment: `[UBUNTU-CLI]`.

## Milestone 14 — PC Handoff
**Status: NOT STARTED**

- Objective: Ensure `docs/pc_handoff.md` is accurate and a fresh clone opens
  cleanly in Godot 4.x Editor.
- Environment: `[GITHUB]` → `[PC-GODOT]`.

## Milestone 15 — Visual Integration and Polish
**Status: NOT STARTED — REQUIRES PC**

- Objective: Creature/environment art, obstacle visuals, UI layout,
  animation, particles, shaders, lighting, atmosphere, audio mixing, feel
  polish.
- Environment: `[PC-GODOT]`.

## Milestone 16 — Android Build and Release
**Status: NOT STARTED — REQUIRES PC (or verified on-device export)**

- Objective: Export template setup, signed APK build, install/run on device,
  manual playtest checklist.
- Environment: `[PC-GODOT]` primarily; `[MANUAL-ANDROID]` for install/playtest.
  On-device export may be attempted from Termux/Ubuntu but is not assumed to
  work until verified (requires Android SDK build-tools + export templates on
  an arm64 Linux host, which is nonstandard).

---

Do not implement multiple milestones in a single step. Update this file's
status lines as milestones progress, and mirror current state in
`docs/current_status.md`.
