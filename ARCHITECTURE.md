# Architecture

BREATHE is code-first but not code-only. Core gameplay must be understandable
and testable without the Godot visual editor; scenes (`.tscn`) are used where
they genuinely help (UI, visual composition, animation, particles).

## Layers

```
GAME LOGIC    — rules, rules only. No rendering, no input polling.
INPUT         — translates raw touch/hold/release into intent events.
PHYSICS       — position/velocity integration for player and world.
STATE         — game state machine (menu / playing / dead / restart).
WORLD         — obstacle spawning, scrolling, difficulty curve.
UI            — HUD, menus, restart prompt. Scene-driven where useful.
AUDIO         — sound/music triggers, on/off setting.
PERSISTENCE   — local high-score save/load.
```

## Principles

- Game state, player logic, breathing mechanic, movement, collision logic,
  scoring, difficulty, persistence, and procedural spawning are implemented
  as plain GDScript classes/autoloads wherever practical, so they can be
  exercised from `--headless` runs and simple test scripts without opening
  the editor.
- `.tscn` scenes are used for things that benefit from visual/editor-driven
  iteration: UI layout, animation, particles, asset composition. Core
  gameplay must not depend on manually wiring things in the editor.
- Avoid premature abstraction. Start with the smallest structure that
  satisfies the current milestone; let it evolve.

## Directory Map

```
scripts/core     — game state machine, shared constants/singletons
scripts/player   — player controller, breathing mechanic
scripts/world    — scrolling world, obstacle spawning, difficulty
scripts/systems  — collision, scoring, persistence
scripts/ui       — HUD/menu logic (non-visual glue)
scripts/audio    — audio bus control, sound triggers
tests/           — headless-runnable test scripts
assets/          — sprites, audio, fonts, shaders (placeholders until PC polish)
scripts_dev/     — validate.sh, test.sh, build.sh, export_android.sh
```

This structure may evolve as milestones progress. Do not overengineer ahead
of actual need.
