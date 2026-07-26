# Current Status

_Last updated: 2026-07-26_

## CURRENT MILESTONE

Milestone 10 — Score and Persistence

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

## BRANCH

`main`

## LATEST STABLE COMMIT

`6db9f42` — "feat: add scoring and local high-score persistence (Milestone 10)"

## COMPLETED

- Milestones 0-9: see ROADMAP.md and earlier CHANGELOG entries.
- **Milestone 10 — scoring and persistence:**
  - `Score` (`scripts/systems/score.gd`): pure `compute(distance_traveled)`,
    a single source of truth for the distance-to-score scale factor
    (`DISTANCE_PER_POINT = 10.0`).
  - `HighScorePersistence` (`scripts/systems/high_score.gd`):
    `load_high_score()`/`save_high_score()` via `FileAccess` at an
    overridable `save_path` (default `user://high_score.save`, stored as a
    raw 32-bit int). `record_score(score)` only saves and returns `true`
    when `score` strictly exceeds the current high score.
  - `world.gd`: reused `CollisionSystem.check_obstacles()`'s own return
    value (`true` exactly when death was triggered *this frame*) to call
    `high_score.record_score(Score.compute(scroll_manager.distance_traveled))`
    exactly once per run - no separate guard flag needed.

## TESTED

- `tests/test_score.gd` (4/4): scaling, flooring, monotonicity.
- `tests/test_high_score.gd` (10/10): no save file initially; only
  strictly-greater scores are recorded; persists correctly across
  load/save cycles. Uses a throwaway per-run `user://` path
  (`test_high_score_<ticks>.save`), verified cleaned up afterward - never
  touches or depends on a real save file.
- Confirmed via direct inspection of the Godot user data directory
  (`~/.local/share/godot/app_userdata/BREATHE/`) that the real project-boot
  smoke check does **not** create a stray `high_score.save` - `GameState`
  never reaches `PLAYING` there, so `died_this_frame` is always false and
  `record_score()` is never called during that check.
- All previous tests still pass unchanged - 103 total assertions across
  12 test files.
- `scripts_dev/validate.sh`, `test.sh`, `build.sh` all pass.

## NOT TESTED

- Godot Editor GUI (deferred to PC).
- Android SDK / export template setup.
- **The World-level score-recording wiring itself** - like the Milestone 8
  collision wiring, this only fires once a real game session actually
  reaches `PLAYING` then `DEAD`, which requires Milestone 11's GameState/UI
  flow. Not exercised by any headless test (same accepted limitation as
  Milestone 8/9's `get_game_state()`-gated code paths).
- Visual/feel verification carried over from Milestones 5, 6, 8, 9 -
  still outstanding, still requires `[MANUAL-ANDROID]` or `[PC-GODOT]`.
  Milestone 10 has no new visual component (no UI yet - that's Milestone
  11), so it doesn't add to this backlog.

## KNOWN ISSUES

- RAM is tight on this device (~700 MiB "available" observed during
  discovery). Avoid heavy concurrent processes when running Godot.
- Visual/feel checks for Milestones 5, 6, 8, 9 remain overdue - not a
  blocker for continued logic-first progress, but this backlog is growing
  and shouldn't be deferred indefinitely.

## BLOCKERS

None. Android export tooling remains an open question (see
`docs/android_build.md`).

## NEXT ACTION

Begin Milestone 11 (UI and Game States): wire `GameState` transitions into
an actual menu/playing/dead/restart flow, and a minimal UI (score display,
restart prompt). This is also the milestone that will finally let the
Milestone 7-10 death/score/persistence wiring actually fire in a real
session (GameState reaching PLAYING for the first time) - a natural point
to also do the overdue visual/feel pass across Milestones 5, 6, 8, 9.

## NEXT ENVIRONMENT

`[HYBRID]` (state machine wiring is `[UBUNTU-CLI]`; UI layout benefits from
`[PC-GODOT]`); `[MANUAL-ANDROID]`/`[PC-GODOT]` increasingly overdue for
feel verification
