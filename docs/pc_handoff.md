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
   the project is scanned by the actual Editor - see the note in
   `docs/current_status.md` about `class_name` global resolution; nothing
   should break, but this is worth watching for on first import.
3. Run the project (F5) and confirm it launches into `world.tscn` (the
   current `main_scene` - a Player swimming forward through placeholder
   scroll markers, controlled by hold/release). See
   `docs/current_status.md` for exactly what's implemented vs. not.
4. Read `ROADMAP.md` for the milestone plan.
5. Read `ARCHITECTURE.md` for the code layout/principles.
6. Read `docs/current_status.md` for exactly what's done vs. not.
7. Continue with the next milestone.

## Current project state

See `docs/current_status.md` — kept up to date after every session. As of
this writing, the project is through Milestone 12: there's a complete
playable loop (tap to start → hold/release to breathe → collide with a
procedurally-spawned obstacle → die → tap to restart), with score,
persistence, and audio routing all wired in. `world.tscn` is `main_scene`.

## Known limitations (as of Milestone 12)

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
- Android export, signing, install, and manual playtest — see Milestone 16.
- Performance profiling, gameplay feel tuning.

## Tasks that don't need PC

- Everything in `scripts/`, `tests/`, game logic, headless-testable systems
  — these should continue to be developed from Android/Termux where
  possible; there's no need to wait for a PC session to make this kind of
  progress.

## Recommended next step

Check `docs/current_status.md` → "NEXT ACTION" for the precise next step at
the time you pick this up.
