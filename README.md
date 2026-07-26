# BREATHE

**Breathe. Rise. Survive.**

A minimalist, atmospheric arcade/survival mobile game. The player controls a
small bioluminescent creature in an abstract underwater world.

## Core Interaction

```
HOLD    → INHALE → RISE
RELEASE → EXHALE → DESCEND
```

Simple to understand, difficult to master. Endless survival — beat your
previous record.

## Project Status

See [docs/current_status.md](docs/current_status.md) for the current
milestone and development snapshot, and [ROADMAP.md](ROADMAP.md) for the
full milestone plan.

## Development Model

This project is developed hybrid-style:

- **Android (Termux → Ubuntu proot-distro → Claude → Git → GitHub)** for
  code-first work: game logic, systems, tests, documentation, automation.
- **PC (Godot 4.x Editor)** for visual composition, animation, particles,
  shaders, asset placement, polish, profiling, and Android release builds.

GitHub is the canonical source of truth and the handoff point between the
two environments. See [docs/pc_handoff.md](docs/pc_handoff.md) for how to
pick up development on a PC.

## Engine

[Godot 4.x](https://godotengine.org/) (GDScript, code-first core, scenes
used where they add clear value for visual/UI work).

## Getting Started

See [docs/setup.md](docs/setup.md) for environment requirements and
verified toolchain versions, and [docs/development_workflow.md](docs/development_workflow.md)
for the day-to-day workflow.

## License

See [LICENSE](LICENSE).
