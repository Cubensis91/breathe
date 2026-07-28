extends Node2D

## Manual playtest harness for the two-entity orbit pivot (Milestone 17).
## Not part of the reusable PlayerPair architecture - exists only so this
## scene can be opened directly in the Godot Editor and run standalone
## (Scene -> Run Current Scene / F6), without going through World's
## tap-to-start flow. GameState defaults to MENU, and
## BreathingController's input gate (see breathing_controller.gd's
## _unhandled_input) silently ignores hold/release input unless
## GameState.is_playing() - so this forces that transition once on ready.

func _ready() -> void:
	var game_state = get_node_or_null("/root/GameState")
	if game_state and not game_state.is_playing():
		game_state.transition_to(game_state.State.PLAYING)
