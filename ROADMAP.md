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
**Status: COMPLETED (rule) — runtime wiring deferred to Milestone 8**

- Objective: Collision detection between player and obstacles, death trigger.
- What landed: `scripts/systems/collision_system.gd` (`CollisionSystem`,
  `RefCounted`, static methods only):
  - `circles_overlap(pos_a, radius_a, pos_b, radius_b)` - pure circle-circle
    overlap geometry (touching counts as overlapping).
  - `check_obstacles(player_position, player_radius, obstacles, game_state)`
    - checks a list of obstacles (each a `Dictionary` with `"position"` and
    `"radius"`) against the player, and calls
    `game_state.transition_to(game_state.State.DEAD)` if any overlap while
    `game_state.is_playing()`. Returns whether it triggered death.
  - `game_state` is passed in explicitly rather than reaching for the
    `GameState` autoload directly, matching the pattern established by
    `tests/test_game_state.gd` (isolated instances for testing, not global
    state) and keeping this fully unit-testable.
  - Obstacles are represented as plain `Dictionary`s rather than a formal
    `Obstacle` class/scene, because **there are no real obstacle nodes
    yet** (Milestone 8). Wiring this into `Player`/`World`'s actual physics
    loop - reading real `CollisionShape2D` radii, iterating real obstacle
    instances each frame, calling this with live data - is explicitly
    Milestone 8's job, once there's something real to check against.
    Building that wiring now against a placeholder obstacle shape would be
    guesswork about Milestone 8's design.
- Acceptance criteria: overlapping/non-overlapping/exactly-touching circle
  geometry all correct; `check_obstacles` triggers `DEAD` only when playing
  and only when something actually overlaps; it's a no-op once no longer
  `PLAYING` (won't re-trigger or throw after death). `tests/test_collision_system.gd`:
  8/8 assertions pass, no live scene tree or physics frames needed.
- Dependencies: Milestones 3, 4.
- Environment: `[UBUNTU-CLI]`. Headless testable: Yes (geometry/logic) -
  done. Runtime/physics-engine integration and manual verification that
  collisions actually feel/read correctly: Milestone 8 + later
  `[MANUAL-ANDROID]`/`[PC-GODOT]`.

## Milestone 8 — Static and Moving Obstacles
**Status: PARTIALLY COMPLETED** — logic/wiring done and tested; visual feel unverified

- Objective: One static obstacle type, one moving obstacle type.
- What landed:
  - `scripts/world/obstacle.gd` (`Obstacle`, `Node2D`) - the static type:
    just an exported `radius` and a scene position. "Static" means there's
    no movement script at all. No `Area2D`/`CollisionShape2D` - Milestone 7
    already decided collision is pure geometry, not physics-engine overlap,
    so no physics body is needed.
  - `scripts/world/moving_obstacle.gd` (`MovingObstacle`, extends
    `obstacle.gd` via file-path `extends`) - the moving type: vertical sine
    oscillation around an explicit `origin_y`, via a pure
    `compute_offset_y(elapsed_time)` and `advance(delta)`. `origin_y` is
    set explicitly (matching the node's scene position) rather than
    captured in `_ready()`, avoiding any tree-entry timing dependency.
  - `obstacle.tscn` / `moving_obstacle.tscn` - placeholder `Polygon2D`
    visuals (red / orange squares) matching each script.
  - `player.gd` gained an exported `radius` (16.0, matching its
    `CollisionShape2D`) so `Player` exposes the same position+radius
    contract `Obstacle` does - both sides `CollisionSystem` needs.
  - `world.gd`: `gather_obstacles()` collects direct children that are
    `Obstacle` instances (structural check via `is ObstacleScript`, no live
    tree needed) into the `{"position", "radius"}` shape
    `CollisionSystem.check_obstacles()` expects. `get_game_state()` looks
    up the real `GameState` autoload via `get_node_or_null("/root/GameState")`
    - **not** the bare `GameState` identifier, which turned out to fail to
    even *compile* when a script is loaded via `godot4 --headless -s`
    (confirmed by direct probe) since autoloads are only injected as
    globals during a real project boot. `is_inside_tree()` guards this
    lookup so it degrades to a quiet no-op in tests instead of logging
    absolute-path errors. `step()` now calls
    `CollisionSystem.check_obstacles()` whenever a real game_state is found.
  - `world.tscn` gained one `Obstacle` instance (700, 550) and one
    `MovingObstacle` instance (1100, 640, amplitude 150, period 3s).
- Acceptance criteria: `Obstacle`/`MovingObstacle` scenes instantiate with
  correct default/overridable radius; oscillation math is correct at
  quarter/half/three-quarter period; `World.gather_obstacles()` correctly
  collects exactly the 2 real obstacles (not `Player`, not the 4 cosmetic
  Markers); `get_game_state()` is null under `-s` test mode and `step()`
  doesn't crash when it is. `tests/test_obstacle.gd` (5/5),
  `tests/test_moving_obstacle.gd` (8/8), extended `tests/test_world.gd`
  (12/12, was 6/6) all pass. Project still boots headlessly with the real
  `GameState` autoload wired through `World.step()` without error (this is
  the first time that code path has actually run against the real
  singleton, even though `GameState` starts at MENU so no death trigger
  fires during the boot check).
- Acceptance criteria (visual/feel): **not yet verified** - same carried-over
  debt as Milestones 5-6. Nobody has looked at the obstacles rendering,
  the oscillation feeling right, or an actual collision happening on screen.
- Dependencies: Milestones 6, 7.
- Environment: `[UBUNTU-CLI]` for logic (done, headlessly tested).
  `[PC-GODOT]`/`[MANUAL-ANDROID]` for visual placement/feel (not done).

## Milestone 9 — Endless Mode and Difficulty
**Status: PARTIALLY COMPLETED** — logic/wiring done and tested; visual feel unverified

- Objective: Procedural obstacle spawning, difficulty scaling over
  time/distance.
- What landed:
  - `scripts/world/difficulty_curve.gd` (`DifficultyCurve`, `RefCounted`):
    pure `compute_scroll_speed(distance_traveled)` - linear ramp from
    `base_speed` (200) up to a `max_speed` cap (500) via `ramp_rate`.
  - `scripts/world/scroll_manager.gd` updated: `scroll_speed` is no longer
    constant - `advance(delta)` now recomputes it from `distance_traveled`
    via an owned `DifficultyCurve` after advancing distance (current speed
    integrates position first, then the new distance informs next step's
    speed - same "integrate then update" order `Player.integrate_physics`
    already uses for velocity).
  - `scripts/world/obstacle_spawner.gd` (`ObstacleSpawner`, `RefCounted`):
    the WHEN-to-spawn rule, decoupled from Godot nodes/scenes. `should_spawn
    (distance_traveled)` returns true once `distance_traveled` crosses
    `next_spawn_distance`, then advances that threshold by
    `compute_interval(distance_traveled)` - a spacing that tightens (down
    to `min_interval`) as distance grows, so obstacles come faster over a
    longer run. Deciding WHAT/WHERE to spawn and actually instancing nodes
    stays in `world.gd` - Godot-specific side effects don't belong in this
    pure timing rule.
  - `world.gd`: `_spawn_obstacle()` instances a random `Obstacle` or
    `MovingObstacle` ahead of the player (`spawn_lookahead_x` = 900,
    random Y within a placeholder-tuned band) whenever
    `spawner.should_spawn()` fires each `step()`. `_despawn_old_obstacles()`
    frees any obstacle that's fallen more than `despawn_margin_x` (300)
    behind the player, keeping the scene tree bounded over an endless run.
  - `world.tscn` no longer hand-places any obstacles (Milestone 8's
    `Obstacle1`/`MovingObstacle1` removed along with their now-unused
    `ext_resource` entries) - spawning is fully procedural now.
- Acceptance criteria: difficulty speed ramp is correct and capped
  (`tests/test_difficulty_curve.gd`, 5/5); `ScrollManager.advance()` stays
  self-consistent with the difficulty curve and never exceeds `max_speed`
  after many steps (`tests/test_scroll_manager.gd`, 7/7); spawn-timing
  thresholds and interval-tightening are correct
  (`tests/test_obstacle_spawner.gd`, 9/9); `World` starts with zero
  obstacles, spawns at least one after enough distance, and stays bounded
  (not unbounded growth) over a long simulated run
  (`tests/test_world.gd`, 15/15, was 12/12).
- Acceptance criteria (visual/feel): **not yet verified** - same
  carried-over debt as Milestones 5, 6, 8. Nobody has watched obstacles
  actually spawn/scroll/despawn on screen, or felt whether the difficulty
  ramp feels fair.
- Dependencies: Milestones 6, 8.
- Environment: `[UBUNTU-CLI]`. Headless testable: Yes (spawn/difficulty
  curves) - done. Visual feel: `[MANUAL-ANDROID]`/`[PC-GODOT]` (not done).

## Milestone 10 — Score and Persistence
**Status: COMPLETED**

- Objective: Distance/time-based scoring, local high-score save/load.
- What landed:
  - `scripts/systems/score.gd` (`Score`, `RefCounted`, static method only):
    `compute(distance_traveled)` - a single pure function converting raw
    distance (px, from `ScrollManager`) into a display score
    (`DISTANCE_PER_POINT = 10.0`), so the scale factor has one source of
    truth instead of getting duplicated in World/UI code later.
  - `scripts/systems/high_score.gd` (`HighScorePersistence`): `load_high_score()`/
    `save_high_score()` via Godot's `FileAccess`, storing a raw 32-bit
    integer at an overridable `save_path` (default `user://high_score.save`).
    `record_score(score)` is the orchestration rule: saves and returns
    `true` only if `score` strictly exceeds the current high score,
    otherwise leaves the save untouched and returns `false`.
  - `world.gd`: reused `check_obstacles()`'s own return value (`true`
    exactly when death was triggered *this frame*) to call
    `high_score.record_score(Score.compute(scroll_manager.distance_traveled))`
    exactly once per run, with no extra guard flag needed.
- Acceptance criteria: `Score.compute()` scales/floors correctly and is
  monotonic (`tests/test_score.gd`, 4/4); `HighScorePersistence` correctly
  reports no save file initially, only records strictly-greater scores,
  and persists across load/save cycles, using a throwaway per-run test
  path cleaned up afterward so it never touches or depends on a real save
  (`tests/test_high_score.gd`, 10/10). Confirmed the real project-boot
  smoke check never creates a stray `user://high_score.save` (GameState
  never reaches `PLAYING` yet, so `died_this_frame` is always false there).
- Dependencies: Milestones 3, 7, 9.
- Environment: `[UBUNTU-CLI]`. Headless testable: Yes - done. The World-level
  wiring (recording on death) is glue code exercised only once a real game
  session reaches `PLAYING`/`DEAD` (Milestone 11), same limitation already
  accepted for the Milestone 8 collision wiring.

## Milestone 11 — UI and Game States
**Status: PARTIALLY COMPLETED** — logic done and tested where headlessly
possible; the autoload-gated code paths and all visual/feel verification
remain outstanding

- Objective: Menu / playing / dead / restart states, minimal UI.
- What landed:
  - `world.gd`: `step()` is now a no-op unless `GameState.is_playing()` -
    the world freezes during MENU/DEAD instead of continuing to scroll/
    spawn/collide. Under `-s` tests `get_game_state()` is always null, so
    this check never triggers there and all prior test behavior is
    unaffected (verified - no test changes needed for this part).
  - `world.gd`: `reset_session()` - rebuilds `scroll_manager`/`spawner`
    from scratch, restores the player to `player_start_position` with zero
    velocity and `is_holding = false`, and clears all obstacle children.
    Reached via `_on_game_state_changed(previous, current)`, connected to
    `GameState.state_changed` lazily on the *first* `step()` call (not
    `_ready()`, avoiding tree-entry timing dependence entirely) so a
    transition into `PLAYING` - whether the first start from `MENU` or a
    restart from `DEAD` - always resets the session exactly once.
  - `world.gd`: `is_tap_event(event)` (pure static) + `_unhandled_input()` -
    tapping while not playing calls `game_state.transition_to(PLAYING)`,
    covering both "start" and "restart" with one gesture (both are already
    legal transitions in `game_state.gd`).
  - `breathing_controller.gd`: `_unhandled_input` now ignores touch/mouse
    events unless `GameState.is_playing()`, using the same lazy
    `get_node_or_null("/root/GameState")` lookup pattern as `world.gd`.
  - `scripts/ui/hud.gd` + `hud.tscn` (`Hud`, `CanvasLayer`): a single
    `Label` showing state-appropriate text. `compute_display_text(state,
    score, high_score)` is a pure static function (menu prompt / live
    score / death summary + restart prompt); the rest is presentation
    glue reading `World.get_current_score()`/`get_high_score()`. Added as
    a child of `World` in `world.tscn`.
- **Key discovery**: attempted to test the full autoload-gated flow
  end-to-end by manually building a live tree (`SceneTree.root` + a
  hand-named `"GameState"` node) inside a `-s` test, the same technique
  that worked for scene structure elsewhere. It doesn't work here - a
  direct probe confirmed that even `-s` mode's own `SceneTree.root`
  reports "not in a scene tree" for absolute-path (`/root/...`)
  resolution. So `get_game_state()`, and anything gated purely on it (the
  freeze check, the tap handler's early-out), are **only exercised by a
  real project boot** - manual/PC testing territory. This is the same
  limitation already accepted for the Milestone 8-10 `GameState`-gated
  code paths, now confirmed to be a hard constraint of `-s` script mode
  rather than something a cleverer test could work around.
  `reset_session()` and `_on_game_state_changed()` themselves take no
  tree/GameState dependency at all, so those *are* tested directly.
- Acceptance criteria: `reset_session()`/`_on_game_state_changed()`
  correctly reset (and don't incorrectly reset) session state, verified by
  direct calls with synthetic before/after state values;`is_tap_event()`
  correctly classifies touch/mouse events; `Hud.compute_display_text()`
  correct for all 3 states; `hud.tscn` has the expected node structure.
  Extended `tests/test_world.gd` (27/27, was 15/15), new
  `tests/test_hud.gd` (8/8). Project still boots headlessly with the HUD
  present, no errors.
- Acceptance criteria (visual/feel + full flow): **not yet verified** -
  same carried-over debt as Milestones 5, 6, 8, 9, plus this milestone's
  own untested territory: does tapping to start/restart actually work on a
  real touchscreen, does the HUD text read clearly, does the freeze-on-
  death feel right. This is now the natural point to finally do that
  overdue manual/PC pass, since a full session (start -> play -> die ->
  restart) exists to test for the first time.
- Dependencies: Milestones 3, 4, 5, 6, 7, 9, 10.
- Environment: `[HYBRID]`. State machine logic: `[UBUNTU-CLI]`, headlessly
  tested where the autoload boundary doesn't block it (done). Full-flow
  and UI layout: `[MANUAL-ANDROID]`/`[PC-GODOT]` (not done).

## Milestone 12 — Audio System
**Status: PARTIALLY COMPLETED** — routing/settings logic done and tested;
no real audio assets exist yet, so there is nothing audible to verify

- Objective: Inhale, collision, game-over sounds; one music loop; on/off
  setting.
- What landed:
  - `scripts/audio/audio_settings.gd` (`AudioSettings`): on/off setting
    via `FileAccess`, same pattern as `HighScorePersistence` (overridable
    `save_path`, defaults to enabled when no save exists).
  - `scripts/audio/audio_controller.gd` + `audio_controller.tscn`
    (`AudioController`, `Node` with 4 `AudioStreamPlayer` children -
    Inhale, Collision, GameOver, Music): `play_inhale()`/`play_collision()`/
    `play_game_over()`/`start_music()`/`stop_music()`, all gated by
    `AudioSettings.is_enabled()` and safely no-op if a stream isn't
    assigned. **No real audio assets exist in this environment** - every
    `AudioStreamPlayer` has `stream = null`. Adding real sound/music later
    is purely an asset change (assign a stream in the scene) - no code
    here needs to change, matching the project's placeholder-asset
    principle.
  - `breathing_controller.gd`: new `inhale_started` signal, emitted
    exactly on the false -> true hold transition (not every hold call, not
    on release) - kept as a plain signal with no audio dependency, so
    BreathingController itself stays decoupled from the AUDIO layer.
  - `world.gd`: wires `AudioController` in three places -
    `breathing.inhale_started` connected to `audio.play_inhale` (a
    structural connection needing no tree/autoload, unlike the
    `GameState` connection - `_ensure_audio_connected()`, called from
    `step()`); `play_collision()`/`play_game_over()` called at the same
    moment `check_obstacles()` reports death; `start_music()` called
    alongside `reset_session()` when transitioning into `PLAYING`.
  - `world.tscn`: added `AudioController` as a child of `World`.
- Acceptance criteria: `AudioSettings` correctly defaults/persists/toggles
  (`tests/test_audio_settings.gd`, 7/7); `AudioController` has the
  expected 4 stream-less children and every routing method is safe to
  call with audio enabled or disabled
  (`tests/test_audio_controller.gd`, 12/12); `inhale_started` fires
  exactly on the hold-start transition, not on repeated holds or on
  release (extended `tests/test_breathing_controller.gd`, 12/12, was 8/8).
  Project still boots headlessly with `AudioController` present.
- Acceptance criteria (audible sound): **not applicable yet** - there is
  no audio content in this environment to hear. This isn't a deferred
  verification like the visual/feel backlog elsewhere; it's a genuine
  content gap. `docs/pc_handoff.md` flags that adding real audio
  files (inhale/collision/game-over SFX, one music loop) is PC work with
  no code changes required.
- Dependencies: Milestones 5, 7, 10, 11.
- Environment: `[HYBRID]`. Routing/settings logic: `[UBUNTU-CLI]`,
  headlessly tested (done). Actual sound content and feel:
  `[PC-GODOT]` (assets) then `[MANUAL-ANDROID]` (verification) - not done,
  blocked on real audio assets existing at all.

## Milestone 13 — Automated Validation and Testing
**Status: COMPLETED**

- Objective: Consolidate headless test suite covering state transitions,
  scoring, movement, collision, difficulty, spawning, persistence, config.
- What landed: since tests have been written incrementally throughout
  every prior milestone (not deferred to this one), the objective's areas
  were already almost entirely covered by the existing 15-file/146-
  assertion suite. This milestone's actual work was auditing that
  suite for real gaps and consolidating, not writing tests for quantity:
  - **Found and fixed one real gap**: `tests/test_game_state.gd` tested
    5 of the 6 (from, to) pairs in `_ALLOWED_TRANSITIONS` (plus a no-op
    self-transition), but never `MENU -> DEAD` (the one remaining illegal
    pair). Added it - now every transition pair the state machine can be
    asked to make has a direct test. 17/17 (was 15/15).
  - **`scripts_dev/test.sh`** now parses each test file's own
    `<name>: N passed, M failed` summary line and prints a suite-wide
    total (`TEST: TOTAL 148 passed, 0 failed, across 15 file(s)`) instead
    of only a per-file pass/fail list - verified against both a fully
    passing run and a deliberately-injected failing test (added and
    removed as a temporary probe, confirmed correct detection/reporting
    in both cases, confirmed no trace left behind).
  - **Documented the testing convention** in
    `docs/development_workflow.md` ("Writing tests"): the
    `SceneTree`/`_check`/summary-line shape test.sh depends on, and four
    hard-won lessons future test-writing should account for -
    `preload()` over `class_name` resolution, the `-s` mode
    autoload/absolute-path limitation (confirmed via direct probe, not
    assumed), the GDScript lambda-capture-by-value gotcha (hit in
    Milestone 12), and preferring real invariants over timing-dependent
    assertions (a lesson from a flaky check removed in Milestone 9).
- Acceptance criteria: audited existing coverage against the objective's
  named areas (state transitions, scoring, movement, collision,
  difficulty, spawning, persistence, config) - all covered, one genuine
  gap found and closed. `scripts_dev/test.sh` aggregate reporting verified
  correct on both pass and fail. Testing convention documented for future
  sessions/PC continuation to follow without reverse-engineering it from
  existing files.
- Dependencies: Milestones 3-12 (this milestone reviews their tests).
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
