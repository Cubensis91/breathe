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
godot4 --headless --path . -s res://tests/some_test.gd   # run one test file
```

## Writing tests

Every `tests/test_*.gd` follows the same shape - a `SceneTree` script run
directly via `godot4 --headless -s <file>` (no `--quit` needed; the script
calls `quit()` itself). `scripts_dev/test.sh` runs all of them and
aggregates their summary lines into a total pass/fail count.

```gdscript
extends SceneTree

const SomeScript = preload("res://scripts/.../some_script.gd")

var _passed := 0
var _failed := 0

func _check(condition: bool, description: String) -> void:
	if condition:
		_passed += 1
	else:
		_failed += 1
		print("FAIL: %s" % description)

func _initialize() -> void:
	# ... assertions via _check() ...
	print("test_some_script: %d passed, %d failed" % [_passed, _failed])
	quit(1 if _failed > 0 else 0)
```

The final `print` line **must** match `<name>: N passed, M failed` exactly
(no extra punctuation) - `test.sh` parses it with `grep` to compute the
suite-wide total. Copy an existing test file as a starting point rather
than writing this boilerplate from scratch each time.

A few hard-won lessons baked into this convention:

- **Prefer `preload()` over relying on `class_name`-based global type
  resolution.** `class_name` only becomes globally resolvable after a
  project scan (normally done by the Godot Editor), which this CLI-only
  workflow never triggers. A bare type name like `Player` or `GameState`
  in a type annotation will fail to *compile* under `-s` script mode.
  `const PlayerScript = preload("res://scripts/player/player.gd")` works
  everywhere regardless of any editor scan having happened.
- **Autoloads are not available under `-s` script mode at all** - not
  just the bare identifier (which fails to compile), but even
  `get_node_or_null("/root/GameState")` returns null, because autoloads
  are only injected as globals during a real project boot (main_scene
  load), which `-s` mode bypasses entirely. Worse, **`-s` mode's own
  `SceneTree.root` can't resolve absolute NodePaths at all** - confirmed
  by direct probe, not just observed - so building a fake live tree by
  hand (`root.add_child(...)`) doesn't work around it either. Code that
  needs an autoload should look it up via `get_node_or_null("/root/Name")`
  guarded by `is_inside_tree()` (quiet `null` in tests, real singleton in
  a genuine project boot), and the corresponding test coverage is
  necessarily split: pure logic that doesn't touch the autoload lookup is
  tested directly; the autoload-gated glue itself is only exercised by a
  real project boot (manual/PC testing) - don't try to force it, just
  document the boundary honestly (see `docs/current_status.md`).
- **GDScript lambda closures capture local variables by value, not
  reference.** A `func(): counter += 1` lambda mutates a *copy* of
  `counter`, not the original - the outer variable never changes. Use a
  single-element `Array` (a reference type) as a mutable counter instead:
  `var counter := [0]; ...connect(func(): counter[0] += 1)`.
- **File-backed persistence tests** (`HighScorePersistence`,
  `AudioSettings`) use an overridable `save_path`, pointed at a throwaway
  `user://test_<name>_<Time.get_ticks_usec()>.save` file, deleted at the
  end of the test. Never test against the real save path - a leftover or
  pre-existing real save would make results depend on execution history.
- **Test what's true, not what's convenient.** If an assertion turns out
  to depend on timing/ordering that isn't actually guaranteed (e.g. "the
  first spawned obstacle is still ahead of the player" - untrue once the
  player has had time to catch up), delete it rather than keep a flaky
  check. Prefer invariants that hold regardless of iteration count/timing.

## Stop rule

If a prerequisite fails: **STOP → IDENTIFY → DIAGNOSE → FIX → TEST →
DOCUMENT → CONTINUE**. Don't build on top of a broken foundation. Label
anything genuinely blocked as `BLOCKED — REQUIRES PC` or
`BLOCKED — REQUIRES MANUAL ANDROID TEST` rather than guessing at success.
