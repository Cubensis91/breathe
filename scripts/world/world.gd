extends Node2D
class_name World

## First real gameplay scene (Milestone 6): ties Player + BreathingController
## together with constant forward motion, producing the endless-world
## illusion. The camera-follow itself needs no code here - Camera2D is a
## child of Player in player.tscn with position_smoothing enabled, so it
## tracks Player's transform automatically.
##
## Not yet gated by GameState (Milestone 3) - that wiring (only scroll while
## PLAYING, etc.) belongs to Milestone 11 (UI and Game States).

const ScrollManagerScript = preload("res://scripts/world/scroll_manager.gd")
const PlayerScript = preload("res://scripts/player/player.gd")

var scroll_manager := ScrollManagerScript.new()

func get_player() -> PlayerScript:
	return get_node_or_null("Player") as PlayerScript

## Advances world state by one timestep. Public (not just the _physics_process
## hook) so tests can call it directly without needing a live engine loop.
func step(delta: float) -> void:
	scroll_manager.advance(delta)
	var player := get_player()
	if player:
		player.velocity.x = scroll_manager.scroll_speed

func _physics_process(delta: float) -> void:
	step(delta)
