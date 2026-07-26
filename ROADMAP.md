# ROADMAP

Milestones are implemented one at a time, smallest logical increment first.
A milestone is only marked **COMPLETED** when its acceptance criteria are
verified. If verification requires a PC or manual Android testing that
hasn't happened yet, it is marked **PARTIALLY COMPLETED**.

Environment tags: `[TERMUX]` `[UBUNTU-CLI]` `[GITHUB]` `[PC-GODOT]`
`[MANUAL-ANDROID]` `[HYBRID]`

---

## Milestone 0 — Environment and GitHub Validation
**Status: IN PROGRESS**

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
**Status: IN PROGRESS**

- Objective: Create `breathe` GitHub repo and initial directory/doc structure.
- Acceptance criteria: All top-level docs exist; folder structure exists;
  pushed to `main`.
- Dependencies: Milestone 0.
- Environment: `[UBUNTU-CLI]` `[GITHUB]`.

## Milestone 2 — Minimal Godot Project
**Status: NOT STARTED**

- Objective: Smallest possible valid `project.godot` that boots and can be
  validated headlessly, proving the CLI pipeline before real gameplay work.
- Acceptance criteria: `godot4 --headless --quit` runs against the project
  without error.
- Dependencies: Milestone 0.
- Environment: `[UBUNTU-CLI]`. Headless testable: Yes. PC required: No.

## Milestone 3 — Core Architecture
**Status: NOT STARTED**

- Objective: Establish the separation of game logic / input / physics /
  state / world / UI / audio / persistence described in ARCHITECTURE.md as
  plain GDScript classes, independent of scenes.
- Environment: `[UBUNTU-CLI]`. Headless testable: Partially (structure and
  unit-testable logic, not rendering). PC required: No.

## Milestone 4 — Player Controller
**Status: NOT STARTED**

- Objective: Player node with position/velocity state, no visuals required
  yet (placeholder shape).
- Environment: `[UBUNTU-CLI]` / `[HYBRID]`. Manual Android test: partial
  (feel). PC required: No for logic, yes eventually for visuals.

## Milestone 5 — Breathing Mechanic
**Status: NOT STARTED**

- Objective: Hold → inhale → rise, release → exhale → descend, as a testable
  input/physics module.
- Environment: `[UBUNTU-CLI]`. Headless testable: movement math only.
  Manual Android test required: touch responsiveness and feel.

## Milestone 6 — World Movement and Camera
**Status: NOT STARTED**

- Objective: Scrolling/endless world illusion, camera following the player.
- Environment: `[HYBRID]`. Camera behavior partially headless-testable;
  visual feel requires manual/PC testing.

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
