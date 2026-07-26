extends CanvasLayer
class_name Hud

## Minimal UI (Milestone 11): a single label showing state-appropriate
## text - menu prompt, live score while playing, or a death summary with
## a restart prompt.
##
## The text-formatting rule is a pure static function so it's testable
## without a live Label/CanvasLayer, even though the rest of this file is
## presentation glue (per ARCHITECTURE.md, UI is "scene-driven where
## useful" and not expected to be as thoroughly unit-tested as game logic).
##
## Expects to be a direct child of a World node (see world.tscn) and a
## direct child named "Label" of its own (see hud.tscn).

const GameStateScript = preload("res://scripts/core/game_state.gd")
const WorldScript = preload("res://scripts/world/world.gd")

static func compute_display_text(state: int, current_score: int, high_score: int) -> String:
	match state:
		GameStateScript.State.MENU:
			return "BREATHE\nHold to rise, release to fall\nTap to start"
		GameStateScript.State.PLAYING:
			return "Score: %d" % current_score
		GameStateScript.State.DEAD:
			return "Score: %d\nBest: %d\nTap to restart" % [current_score, high_score]
		_:
			return ""

func get_game_state():
	if not is_inside_tree():
		return null
	return get_node_or_null("/root/GameState")

func get_world() -> WorldScript:
	return get_node_or_null("..") as WorldScript

func _process(_delta: float) -> void:
	var label := get_node_or_null("Label")
	if not label:
		return

	var game_state = get_game_state()
	var state: int = game_state.current_state if game_state else GameStateScript.State.MENU

	var world := get_world()
	var current_score := 0
	var high_score_value := 0
	if world:
		current_score = world.get_current_score()
		high_score_value = world.get_high_score()

	label.text = compute_display_text(state, current_score, high_score_value)
