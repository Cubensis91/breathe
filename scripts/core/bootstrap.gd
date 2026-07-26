extends Node

## Milestone 2 pipeline-validation scene. Proves the project boots headlessly
## end-to-end (Godot CLI -> scene load -> script run). Replaced by the real
## game bootstrap once Milestone 3 (Core Architecture) begins.

func _ready() -> void:
	print("BREATHE bootstrap: pipeline validation OK")
	assert(GameState.is_menu(), "GameState autoload should default to MENU")
	print("BREATHE bootstrap: GameState autoload wired, state=%s" % GameState.State.keys()[GameState.current_state])
