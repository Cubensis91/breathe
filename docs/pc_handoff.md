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
1. Open the project in Godot 4.x Editor (`project.godot` at repo root, once
   Milestone 2 has created it — see `docs/current_status.md` for whether
   this exists yet).
2. Verify the project imports without errors.
3. Run the project (F5) and confirm it launches.
4. Read `ROADMAP.md` for the milestone plan.
5. Read `ARCHITECTURE.md` for the code layout/principles.
6. Read `docs/current_status.md` for exactly what's done vs. not.
7. Continue with the next milestone.

## Current project state

See `docs/current_status.md` — kept up to date after every session. As of
this writing, the project is at Milestone 0/1 (environment validation +
repository bootstrap); no gameplay code exists yet.

## Known limitations (as of bootstrap)

- Android SDK / export template setup has **not** been done or verified
  on-device. See `docs/android_build.md`. This is expected to be resolved
  on PC (Milestone 16), not on Android.
- No visual assets exist yet — placeholders only, once gameplay milestones
  begin. Placeholder assets are designed to be swappable without gameplay
  code changes.
- Godot Editor GUI has not been run at all yet (only the headless CLI, from
  the Android/Termux side). First PC session should confirm the project
  opens cleanly in the actual Editor.

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
