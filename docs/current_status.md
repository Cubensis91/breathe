# Current Status

_Last updated: 2026-07-26_

## CURRENT MILESTONE

Milestone 11 — UI and Game States

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

## BRANCH

`main`

## LATEST STABLE COMMIT

(pending — this session's commit not yet made at time of writing; see
`git log` for the actual latest hash)

## COMPLETED

- Milestones 0-10: see ROADMAP.md and earlier CHANGELOG entries.
- **Milestone 11 — GameState wired into a full flow, minimal UI:**
  - `world.gd`: `step()` freezes (no-op) unless `GameState.is_playing()`.
  - `world.gd`: `reset_session()` resets `scroll_manager`/`spawner` from
    scratch, restores the player to `player_start_position` with zero
    velocity and `is_holding = false`, clears all obstacles. Reached via
    `_on_game_state_changed()`, connected to `GameState.state_changed`
    lazily on the first `step()` call (not `_ready()` - avoids any
    tree-entry timing dependency).
  - `world.gd`: `is_tap_event()` (pure) + `_unhandled_input()` - tapping
    while not playing transitions to `PLAYING` (covers both start and
    restart with one gesture, since both are already-legal transitions).
  - `breathing_controller.gd`: input now ignored unless `GameState.is_playing()`.
  - `Hud` (`scripts/ui/hud.gd` + `hud.tscn`): single `Label`, pure
    `compute_display_text(state, score, high_score)` for menu/playing/dead
    text, thin `_process()` glue reading `World.get_current_score()`/
    `get_high_score()`. Added as a child of `World`.

## TESTED

- `tests/test_world.gd` extended (27/27, was 15/15): `reset_session()`
  correctly resets (and `_on_game_state_changed()` correctly *doesn't*
  reset for non-PLAYING transitions) when called directly;
  `is_tap_event()` correctly classifies touch/mouse press/release and
  button variants.
- `tests/test_hud.gd` (8/8, new): scene structure; `compute_display_text()`
  correct for all 3 states.
- All previous tests still pass unchanged - 123 total assertions across
  13 test files.
- `scripts_dev/validate.sh`, `test.sh`, `build.sh` all pass, including the
  real project-boot check with the HUD now present in the booted scene.

## NOT TESTED

- Godot Editor GUI (deferred to PC).
- Android SDK / export template setup.
- **The autoload-gated code paths themselves**: `get_game_state()`,
  the freeze-while-not-playing check, and the tap handler's
  `if not game_state` early-out are only exercised by a real project boot.
  **Confirmed via direct probe** (not just assumed) that `-s` script
  mode's own `SceneTree.root` can't resolve absolute `/root/...` NodePaths
  even when a `"GameState"`-named node is manually added to it - so this
  isn't a gap that a cleverer headless test could close; it's a hard
  constraint of the `-s` execution mode used for every test here.
- **A full session end-to-end** (tap to start -> play -> die -> tap to
  restart) has never been observed - requires an actual project boot with
  real touch/mouse input, i.e. manual Android or PC testing.
- Visual/feel verification carried over from Milestones 5, 6, 8, 9 - still
  outstanding. This milestone adds its own untested territory on top: does
  the HUD text read clearly, does tap-to-start/restart feel responsive,
  does the freeze-on-death read correctly.

## KNOWN ISSUES

- RAM is tight on this device (~700 MiB "available" observed during
  discovery). Avoid heavy concurrent processes when running Godot.
- Visual/feel + full-flow verification backlog now spans Milestones 5, 6,
  8, 9, and 11. A full playable session exists for the first time as of
  this milestone - this is a strong point to finally do that manual/PC
  pass before adding more on top.

## BLOCKERS

None for continuing code-first development. Android export tooling remains
an open question (see `docs/android_build.md`).

## NEXT ACTION

Begin Milestone 12 (Audio System): inhale/collision/game-over sounds, one
music loop, on/off setting. Given the size of the accumulated visual/feel
verification backlog, strongly consider a dedicated PC or Android session
before or alongside this milestone - Milestone 11 finally created a
complete playable loop (start/play/die/restart) worth actually seeing and
feeling.

## NEXT ENVIRONMENT

`[HYBRID]` (audio wiring is `[UBUNTU-CLI]`-able for the logic, but audio
*feel* is inherently a `[MANUAL-ANDROID]`/`[PC-GODOT]` concern); a full
manual/PC playtest pass is increasingly the highest-value next step
