# Development Workflow

## Cycle

```
PLAN → IMPLEMENT → TEST → DOCUMENT → COMMIT → PUSH → NEXT MILESTONE
```

One milestone at a time (see `ROADMAP.md`). Never implement multiple
milestones in one step.

## Before touching anything

```bash
git status
git branch --show-current
git log --oneline -5
git remote -v
```

## Per-milestone steps

1. Inspect current repository state.
2. Inspect previous implementation relevant to this milestone.
3. Plan the smallest logical change.
4. Implement it.
5. Test it (`scripts_dev/test.sh`, plus manual notes where headless testing
   isn't possible).
6. Document it (relevant `docs/*.md`, `ROADMAP.md` status line).
7. Commit it (conventional commit message).
8. Push it.
9. Update `docs/current_status.md`.
10. Report completion and the exact next action.

## Commit types

`feat:` `fix:` `refactor:` `test:` `docs:` `chore:` `build:` — see
`CONTRIBUTING.md`.

## Environment classification

Every significant task should be classified as one or more of:
`[TERMUX]` `[UBUNTU-CLI]` `[GITHUB]` `[PC-GODOT]` `[MANUAL-ANDROID]`
`[HYBRID]`

This keeps effort focused on what's actually achievable from the current
device instead of chasing PC-only workflows prematurely.

## Godot CLI reference (on this device)

Binary: `godot4` (aliased via `PATH`, see `docs/setup.md`).

```bash
godot4 --headless --version              # sanity check
godot4 --headless --path . --quit        # open project, run one frame, quit
godot4 --headless --path . --script res://tests/some_test.gd --quit
```

## Stop rule

If a prerequisite fails: **STOP → IDENTIFY → DIAGNOSE → FIX → TEST →
DOCUMENT → CONTINUE**. Don't build on top of a broken foundation. Label
anything genuinely blocked as `BLOCKED — REQUIRES PC` or
`BLOCKED — REQUIRES MANUAL ANDROID TEST` rather than guessing at success.
