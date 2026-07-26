# Current Status

_Last updated: 2026-07-26_

## CURRENT MILESTONE

Milestone 12 — Audio System

## STATUS

Milestone 0 — COMPLETED
Milestone 1 — COMPLETED
Milestone 2 — COMPLETED (superseded: `bootstrap.tscn` deleted, `world.tscn`
is now `main_scene`)
Milestone 3 — COMPLETED (state layer only — see ROADMAP.md note)
Milestone 4 — COMPLETED
Milestone 5 — PARTIALLY COMPLETED (logic done and tested; touch feel unverified)
Milestone 6 — PARTIALLY COMPLETED (logic/wiring done and tested; visual feel unverified)
Milestone 7 — COMPLETED (rule) — runtime wiring landed in Milestone 8
Milestone 8 — PARTIALLY COMPLETED (logic/wiring done and tested; visual feel unverified)
Milestone 9 — PARTIALLY COMPLETED (logic/wiring done and tested; visual feel unverified)
Milestone 10 — COMPLETED
Milestone 11 — PARTIALLY COMPLETED (logic done and tested where headlessly
possible; full-flow and visual feel unverified)
Milestone 12 — PARTIALLY COMPLETED (routing/settings logic done and
tested; no real audio assets exist yet - genuine content gap, not a
deferred check)

## BRANCH

`main`

## LATEST STABLE COMMIT

`dbe48aa` — "feat: add audio routing and settings system (Milestone 12)"

## COMPLETED

- Milestones 0-11: see ROADMAP.md and earlier CHANGELOG entries.
- **Milestone 12 — audio routing and settings:**
  - `AudioSettings` (`scripts/audio/audio_settings.gd`): on/off setting,
    `FileAccess`-backed at an overridable `save_path`, defaults to enabled.
  - `AudioController` (`scripts/audio/audio_controller.gd` +
    `audio_controller.tscn`): 4 `AudioStreamPlayer` children (Inhale,
    Collision, GameOver, Music), all currently stream-less.
    `play_inhale()`/`play_collision()`/`play_game_over()`/`start_music()`/
    `stop_music()` gated by `AudioSettings.is_enabled()`, safe no-ops
    without a stream.
  - `breathing_controller.gd`: new `inhale_started` signal, fires exactly
    on the false -> true hold transition.
  - `world.gd`: wires `AudioController` in - inhale on hold-start
    (structural signal connection, no tree/autoload dependency needed,
    unlike the `GameState` connection); collision/game-over sounds at the
    moment `check_obstacles()` reports death; music starts alongside
    `reset_session()` on entering `PLAYING`.
  - `world.tscn`: `AudioController` added as a child of `World`.

## TESTED

- `tests/test_audio_settings.gd` (7/7): default-enabled, persistence,
  toggle behavior, cleanup.
- `tests/test_audio_controller.gd` (12/12): expected 4 stream-less
  children present; every routing method safe to call with audio enabled
  or disabled and no streams assigned.
- `tests/test_breathing_controller.gd` extended (12/12, was 8/8):
  `inhale_started` fires exactly once per hold-start, not on repeated
  holds or release. (Caught and fixed a GDScript lambda-closure gotcha
  along the way - local variables are captured by value, not reference,
  so the signal-count test needed a single-element Array instead of a
  plain int to actually observe mutations across calls.)
- All previous tests still pass unchanged - 146 total assertions across
  15 test files.
- `scripts_dev/validate.sh`, `test.sh`, `build.sh` all pass, including the
  real project-boot check with `AudioController` now present.
- Confirmed via direct inspection of the Godot user data directory that no
  test artifacts (audio or otherwise) were left behind.

## NOT TESTED

- Godot Editor GUI (deferred to PC).
- Android SDK / export template setup.
- **Any actual sound** - there is no audio content in this environment at
  all (no `.ogg`/`.wav` files under `assets/audio/`). This is a genuine
  content gap, not a deferred verification: adding real inhale/collision/
  game-over SFX and one music loop is pure PC asset work (assign streams
  to the existing `AudioStreamPlayer` nodes) - no code changes needed.
  `docs/pc_handoff.md` flags this explicitly.
- The autoload-gated code paths and full-flow/visual verification carried
  over from Milestones 5, 6, 8, 9, 11 - still outstanding.

## KNOWN ISSUES

- RAM is tight on this device (~700 MiB "available" observed during
  discovery). Avoid heavy concurrent processes when running Godot.
- The visual/feel + full-flow verification backlog (Milestones 5, 6, 8, 9,
  11) continues to grow. A dedicated PC/Android session is increasingly
  the highest-value next step outside pure code work - this would also be
  the natural time to add real audio assets for Milestone 12.

## BLOCKERS

None for continuing code-first development. Android export tooling remains
an open question (see `docs/android_build.md`). Real audio content is
blocked on PC access (asset creation/sourcing), not on anything in this
environment.

## NEXT ACTION

Begin Milestone 13 (Automated Validation and Testing): consolidate and
review the existing headless test suite (15 files, 146 assertions) for
coverage gaps now that most core systems exist. This is a good
opportunity to also assess whether the accumulated visual/feel/audio
backlog should be addressed via a PC/Android session before continuing
further code-only milestones.

## NEXT ENVIRONMENT

`[UBUNTU-CLI]` (test suite consolidation); `[MANUAL-ANDROID]`/`[PC-GODOT]`
increasingly high-value for the growing feel/audio-content backlog
