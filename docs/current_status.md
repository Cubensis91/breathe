# Current Status

_Last updated: 2026-07-26_

## CURRENT MILESTONE

Milestone 13 — Automated Validation and Testing

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
tested; no real audio assets exist yet - genuine content gap)
Milestone 13 — COMPLETED

## BRANCH

`main`

## LATEST STABLE COMMIT

`904d959` — "test: consolidate headless test suite (Milestone 13)"

## COMPLETED

- Milestones 0-12: see ROADMAP.md and earlier CHANGELOG entries.
- **Milestone 13 — test suite consolidation:**
  - Audited the existing 15-file/146-assertion suite against the
    objective's named areas (state transitions, scoring, movement,
    collision, difficulty, spawning, persistence, config) - all already
    covered, since tests were written incrementally throughout every
    prior milestone rather than deferred to this one.
  - Found and fixed the one real gap: `tests/test_game_state.gd` never
    tested `MENU -> DEAD` (the one illegal transition pair not yet
    covered against `_ALLOWED_TRANSITIONS`). Now 17/17.
  - `scripts_dev/test.sh` now parses each test file's own summary line
    and prints a suite-wide total pass/fail count, not just a per-file
    list. Verified correct on both a fully-passing run and a
    deliberately-injected failing test (added and removed as a temporary
    probe to confirm detection/reporting both work).
  - Documented the testing convention in `docs/development_workflow.md`
    ("Writing tests"): the `SceneTree`/`_check`/summary-line shape, plus
    4 hard-won lessons (preload over class_name, the `-s` mode autoload/
    absolute-path limitation, GDScript lambda-capture-by-value, preferring
    real invariants over timing-dependent assertions).

## TESTED

- `tests/test_game_state.gd` extended (17/17, was 15/15): every
  `_ALLOWED_TRANSITIONS` pair (legal and illegal) now has a direct test.
- `scripts_dev/test.sh`'s new aggregation logic tested against both a
  clean pass (148/0 across 15 files) and an injected failure (149/1
  across 16 files, correctly detected and reported, probe file removed
  afterward with the working tree confirmed clean).
- All previous tests still pass unchanged - 148 total assertions across
  15 test files (up from 146/15 due to the 2 new `MENU -> DEAD` checks).
- `scripts_dev/validate.sh`, `test.sh`, `build.sh` all pass.

## NOT TESTED

- Godot Editor GUI (deferred to PC).
- Android SDK / export template setup.
- Everything already flagged as outstanding in Milestones 5, 6, 8, 9, 11,
  12 (visual/feel verification, autoload-gated code paths, real audio
  content) - this milestone was about consolidating what's headlessly
  testable, not addressing that backlog.

## KNOWN ISSUES

- RAM is tight on this device (~700 MiB "available" observed during
  discovery). Avoid heavy concurrent processes when running Godot.
- The visual/feel/audio-content backlog (Milestones 5, 6, 8, 9, 11, 12)
  is now the dominant open item. Milestone 13 deliberately didn't try to
  address it (out of scope - it's about test consolidation), but it
  shouldn't be deferred much further.

## BLOCKERS

None. Android export tooling remains an open question (see
`docs/android_build.md`).

## NEXT ACTION

Begin Milestone 14 (PC Handoff): verify `docs/pc_handoff.md` is fully
accurate (it was refreshed in Milestone 12 but should be re-checked against
the final Milestone 13 state) and confirm a fresh clone's expected
experience opening in Godot 4.x Editor. Given how much has accumulated,
this is also a natural moment to strongly recommend the user actually do a
PC or Android session next, rather than continuing further code-only
milestones - Milestone 15 (Visual Integration and Polish) explicitly
requires PC anyway.

## NEXT ENVIRONMENT

`[GITHUB]` → `[PC-GODOT]` for Milestone 14 verification; a real PC/Android
session is the highest-value next step overall
