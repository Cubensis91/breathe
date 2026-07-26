# Contributing

This is currently a solo project developed across two environments (Android/
Termux and PC/Godot Editor). These conventions exist to keep the project
coherent across both.

## Workflow

1. Inspect current state before changing anything:
   ```
   git status
   git branch --show-current
   git log --oneline -5
   git remote -v
   ```
2. Make the smallest logical change for the milestone in progress.
3. Test it (headless where possible, manual where not).
4. Document it (update relevant `docs/*.md`).
5. Commit it.
6. Push it.

## Branching

- `main` — stable, always releasable.
- `develop` — integration branch, used when working on multi-step milestones.
- `feature/*` — new functionality.
- `fix/*` — bug fixes.

Trivial changes may go straight to `main` if the branch is otherwise stable.
Don't create branches for the sake of it.

## Commit Messages

Conventional commits:

```
feat:     new functionality
fix:      bug fix
refactor: code change with no behavior change
test:     adding or updating tests
docs:     documentation only
chore:    tooling/maintenance
build:    build system / export / CI
```

Commit logical units of work — not every shell command.

## Never

- Commit secrets, tokens, or credentials.
- Force-push without explicit authorization.
- Rewrite history as a shortcut.
- Delete existing work without understanding it first.
