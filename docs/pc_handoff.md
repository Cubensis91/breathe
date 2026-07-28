# PC Handoff

This document lets a PC session pick up development without relying on chat
history. Read this, `ROADMAP.md`, `ARCHITECTURE.md`, and
`docs/current_status.md` before doing anything else.

## Getting started on PC

```bash
git clone https://github.com/Cubensis91/breathe.git
cd breathe
```

Then:
1. Open the project in Godot 4.x Editor (`project.godot` at repo root).
2. Verify the project imports without errors. This will be the first time
   the project is scanned by the actual Editor - see
   `docs/development_workflow.md`'s "Writing tests" section for why
   (`class_name` global resolution never having run is why this codebase
   uses `preload()` everywhere instead). Nothing should break, but this is
   worth watching for on first import.
3. Run the project (F5) and confirm it launches into `world.tscn` (the
   current `main_scene` - a Player swimming forward through placeholder
   scroll markers and procedurally-spawned obstacles, controlled by
   hold/release, with a HUD and a full start/play/die/restart loop). See
   `docs/current_status.md` for exactly what's implemented vs. not.
4. Read `ROADMAP.md` for the milestone plan.
5. Read `ARCHITECTURE.md` for the code layout/principles.
6. Read `docs/development_workflow.md` for the day-to-day workflow and the
   headless testing convention (useful even on PC, where the Editor's
   "Run" button and the `godot4 -s` test scripts complement each other).
7. Read `docs/current_status.md` for exactly what's done vs. not.
8. Continue with the next milestone.

## Current project state

See `docs/current_status.md` — kept up to date after every session. Through
Milestone 13/14 there was a complete playable loop under the original
single-Player vertical-scroll concept (tap to start → hold/release to
breathe → collide with a procedurally-spawned obstacle → die → tap to
restart), with score, persistence, and audio routing all wired in.
`world.tscn` is still `main_scene`.

**2026-07-28: the core gameplay concept is now pivoting** to a two-entity
orbit/energy-bond design ("TWO BEINGS. ONE BREATH. ONE ENERGY BOND. ONE
ASCENT.") — see `ROADMAP.md` Milestone 17 onward for what that means and
what's landed so far (`OrbitController`, pure and tested). Milestones 15/16
below (visual polish, Android build) are on hold until the new mechanic's
vertical slice is validated — read them as historical/deferred, not the
immediate next step. `docs/current_status.md`'s "PC SESSION" section has the
latest detail.

This has been verified from a genuine fresh clone (not just the working
copy this was developed in): `git clone` into a clean directory, then
`scripts_dev/validate.sh`/`test.sh`/`build.sh` all pass identically,
executable bits on `scripts_dev/*.sh` survive the clone correctly, and no
hardcoded machine-specific absolute paths exist anywhere in the tracked
files (checked via `grep` for this device's paths).

## Known limitations (as of Milestone 13)

- Android SDK / export template setup has **not** been done or verified
  on-device. See `docs/android_build.md`. This is expected to be resolved
  on PC (Milestone 16), not on Android.
- **No visual assets exist yet** — the player, obstacles, and scroll
  markers are all flat-colored placeholder shapes (`Polygon2D`). Designed
  to be swappable without gameplay code changes (Milestone 15).
- **No audio assets exist at all** — every `AudioStreamPlayer` in
  `scripts/audio/audio_controller.tscn` (Inhale, Collision, GameOver,
  Music) has no stream assigned. This is a genuine content gap, not just
  a deferred check: adding real sound effects and one music loop is pure
  asset work (drop `.ogg`/`.wav` files under `assets/audio/`, assign them
  to the corresponding `AudioStreamPlayer.stream` property in the editor)
  — no code changes needed. The routing logic (on/off setting, which
  sound plays on which event) is already implemented and tested.
- Godot Editor GUI has not been run at all yet (only the headless CLI, from
  the Android/Termux side). First PC session should confirm the project
  opens cleanly in the actual Editor.
- **Visual/feel verification backlog**: Milestones 5, 6, 8, 9, and 11 all
  have logic that's headlessly tested but has never actually been seen or
  felt running (touch responsiveness, scrolling illusion, obstacle
  appearance/oscillation, camera smoothing, tap-to-start/restart, HUD
  readability). This is the single highest-value thing to check first on
  PC — see `docs/current_status.md`'s "NOT TESTED" sections across those
  milestones for specifics.
- A few `GameState`-gated code paths in `scripts/world/world.gd` (e.g.
  `get_game_state()`, the freeze-while-not-playing check) are only
  exercised by a real project boot — confirmed via direct probe that `-s`
  headless script mode cannot resolve autoloads or absolute `/root/...`
  NodePaths at all, even with a hand-built tree. Opening the project in
  the Editor and playing it is the first real exercise of these paths.

## Tasks best done on PC

- Creature/environment art, obstacle visuals, UI layout and animation,
  particles, shaders, lighting, atmosphere — see Milestone 15.
- Real audio content — inhale/collision/game-over sound effects and one
  music loop. Purely an asset task: drop files under `assets/audio/` and
  assign them to the matching `AudioStreamPlayer.stream` in
  `scripts/audio/audio_controller.tscn` (Inhale/Collision/GameOver/Music).
  No code changes needed — see Milestone 12.
- Android export, signing, install, and manual playtest — see Milestone 16.
- Performance profiling, gameplay feel tuning.
- The visual/feel verification backlog above — this needs a human actually
  playing the game, which isn't possible from this headless environment.

## Tasks that don't need PC

- Everything in `scripts/`, `tests/`, game logic, headless-testable systems
  — these should continue to be developed from Android/Termux where
  possible; there's no need to wait for a PC session to make this kind of
  progress.

## Recommended next step

Check `docs/current_status.md` → "NEXT ACTION" for the precise next step at
the time you pick this up.
