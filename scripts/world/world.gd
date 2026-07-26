extends Node2D
class_name World

## First real gameplay scene (Milestone 6): ties Player + BreathingController
## together with constant forward motion, producing the endless-world
## illusion. The camera-follow itself needs no code here - Camera2D is a
## child of Player in player.tscn with position_smoothing enabled, so it
## tracks Player's transform automatically.
##
## Milestone 8 adds obstacle collection and wires it into
## scripts/systems/collision_system.gd's death-trigger check.
##
## Not yet gated by GameState for scroll/obstacles-only-while-PLAYING - that
## wiring belongs to Milestone 11 (UI and Game States).

const ScrollManagerScript = preload("res://scripts/world/scroll_manager.gd")
const PlayerScript = preload("res://scripts/player/player.gd")
const ObstacleScript = preload("res://scripts/world/obstacle.gd")
const CollisionSystemScript = preload("res://scripts/systems/collision_system.gd")

var scroll_manager := ScrollManagerScript.new()

func get_player() -> PlayerScript:
	return get_node_or_null("Player") as PlayerScript

## Direct children that are Obstacle (or MovingObstacle, which extends it)
## instances, as {"position": Vector2, "radius": float} - the shape
## scripts/systems/collision_system.gd expects. Pure/structural (just reads
## get_children() and each child's own state), so it's testable without a
## live scene tree or GameState.
func gather_obstacles() -> Array:
	var obstacle_data: Array = []
	for child in get_children():
		if child is ObstacleScript:
			obstacle_data.append({"position": child.position, "radius": child.radius})
	return obstacle_data

## The GameState autoload, looked up by absolute NodePath rather than the
## bare "GameState" identifier. Bare autoload identifiers only resolve when
## Godot boots the actual project (autoloads get injected as globals during
## that boot sequence) - they fail to even *compile* when a script is
## loaded via `godot4 --headless -s <script>`, which is how every headless
## test in this project runs. get_node_or_null() is a runtime string
## lookup, so it compiles fine everywhere and simply returns null when
## there's no live autoload to find (e.g. in tests), letting the
## collision-death check degrade to a no-op instead of crashing.
func get_game_state():
	# get_node_or_null() with an absolute path still logs an ERROR (not just
	# a quiet null) when called outside any live tree at all, which is
	# exactly the case in every headless test here. Checking is_inside_tree()
	# first avoids that noise while still finding the real autoload once
	# this World is actually part of a running game.
	if not is_inside_tree():
		return null
	return get_node_or_null("/root/GameState")

## Advances world state by one timestep. Public (not just the _physics_process
## hook) so tests can call it directly without needing a live engine loop.
func step(delta: float) -> void:
	scroll_manager.advance(delta)
	var player := get_player()
	if player:
		player.velocity.x = scroll_manager.scroll_speed
		var game_state = get_game_state()
		if game_state:
			CollisionSystemScript.check_obstacles(player.position, player.radius, gather_obstacles(), game_state)

func _physics_process(delta: float) -> void:
	step(delta)
