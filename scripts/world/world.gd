extends Node2D
class_name World

## First real gameplay scene (Milestone 6): ties Player + BreathingController
## together with constant forward motion, producing the endless-world
## illusion. The camera-follow itself needs no code here - Camera2D is a
## child of Player in player.tscn with position_smoothing enabled, so it
## tracks Player's transform automatically.
##
## Milestone 8 added obstacle collection, wired into
## scripts/systems/collision_system.gd's death-trigger check.
##
## Milestone 9 adds procedural obstacle spawning/despawning
## (scripts/world/obstacle_spawner.gd decides WHEN; this script decides
## WHAT/WHERE and does the actual Godot instancing) and a difficulty ramp
## (scripts/world/scroll_manager.gd now increases scroll_speed with
## distance via scripts/world/difficulty_curve.gd). world.tscn no longer
## hand-places any obstacles - the spawner produces them all.
##
## Milestone 10 adds scoring/persistence: when a collision ends the run,
## the final distance-based score is compared against the saved high
## score exactly once (using check_obstacles()'s own return value to know
## death just happened this frame, rather than a separate guard flag).
##
## Milestone 11 wires GameState into the full flow:
## - step() is a no-op unless GameState.is_playing() - the world freezes
##   during MENU/DEAD instead of continuing to scroll/spawn/collide.
## - Tapping while not playing transitions GameState to PLAYING (covers
##   both "start from MENU" and "restart from DEAD" with the same gesture,
##   since both are already legal transitions - see game_state.gd).
## - Transitioning into PLAYING resets the session (score, obstacles,
##   player position/velocity) via reset_session(), reached through
##   GameState's state_changed signal.
##
## The signal connection is made lazily on the first step() call rather
## than in _ready(), so it doesn't depend on _ready()/tree-entry timing -
## the same reasoning that's kept @onready out of this codebase elsewhere.

const ScrollManagerScript = preload("res://scripts/world/scroll_manager.gd")
const PlayerScript = preload("res://scripts/player/player.gd")
const ObstacleScript = preload("res://scripts/world/obstacle.gd")
const ObstacleScene = preload("res://scripts/world/obstacle.tscn")
const MovingObstacleScene = preload("res://scripts/world/moving_obstacle.tscn")
const ObstacleSpawnerScript = preload("res://scripts/world/obstacle_spawner.gd")
const CollisionSystemScript = preload("res://scripts/systems/collision_system.gd")
const ScoreScript = preload("res://scripts/systems/score.gd")
const HighScorePersistenceScript = preload("res://scripts/systems/high_score.gd")
const GameStateScript = preload("res://scripts/core/game_state.gd")

var scroll_manager := ScrollManagerScript.new()
var spawner := ObstacleSpawnerScript.new()
var high_score := HighScorePersistenceScript.new()

## How far ahead of the player (world-space X) a newly spawned obstacle
## appears - past the right edge of the 720-wide viewport so it scrolls
## into view naturally instead of popping in.
var spawn_lookahead_x: float = 900.0
## Vertical band obstacles can spawn in, leaving margin from the 1280-tall
## viewport's top/bottom edges. Placeholder tuning - not yet playtested.
var spawn_y_min: float = 300.0
var spawn_y_max: float = 980.0
## How far behind the player an obstacle must fall before it's removed.
var despawn_margin_x: float = 300.0

var player_start_position: Vector2 = Vector2.ZERO
var _start_position_captured: bool = false
var _connected_game_state: Object = null

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

func _ensure_start_position_captured() -> void:
	if _start_position_captured:
		return
	var player := get_player()
	if player:
		player_start_position = player.position
		_start_position_captured = true

func _ensure_game_state_connected() -> void:
	var game_state = get_game_state()
	if game_state and game_state != _connected_game_state:
		game_state.state_changed.connect(_on_game_state_changed)
		_connected_game_state = game_state

func _on_game_state_changed(_previous, current) -> void:
	if current == GameStateScript.State.PLAYING:
		reset_session()

## Resets everything a new run needs to start clean: score/distance,
## difficulty, spawn timing, obstacles, and the player's position/velocity/
## breathing state. Called whenever GameState transitions into PLAYING,
## whether that's the first start (from MENU) or a restart (from DEAD).
func reset_session() -> void:
	scroll_manager = ScrollManagerScript.new()
	spawner = ObstacleSpawnerScript.new()

	var player := get_player()
	if player:
		player.position = player_start_position
		player.velocity = Vector2.ZERO
		var breathing = player.get_breathing()
		if breathing:
			breathing.is_holding = false

	var to_remove: Array = []
	for child in get_children():
		if child is ObstacleScript:
			to_remove.append(child)
	for child in to_remove:
		child.free()

func get_current_score() -> int:
	return ScoreScript.compute(scroll_manager.distance_traveled)

func get_high_score() -> int:
	return high_score.load_high_score()

## Instances a new Obstacle or MovingObstacle ahead of the player. Random
## type/position choice - the WHEN decision (should we spawn at all right
## now) already happened in step() via spawner.should_spawn().
func _spawn_obstacle() -> void:
	var player := get_player()
	var spawn_x: float = (player.position.x if player else 0.0) + spawn_lookahead_x
	var spawn_y: float = randf_range(spawn_y_min, spawn_y_max)

	var use_moving := randi() % 2 == 0
	var obstacle = MovingObstacleScene.instantiate() if use_moving else ObstacleScene.instantiate()
	obstacle.position = Vector2(spawn_x, spawn_y)
	if use_moving:
		obstacle.origin_y = spawn_y
	add_child(obstacle)

## Removes obstacles that have fallen far enough behind the player that
## they can no longer be relevant - keeps an "endless" run from growing
## the scene tree without bound.
func _despawn_old_obstacles() -> void:
	var player := get_player()
	if not player:
		return
	var to_remove: Array = []
	for child in get_children():
		if child is ObstacleScript and child.position.x < player.position.x - despawn_margin_x:
			to_remove.append(child)
	for child in to_remove:
		child.free()

## Advances world state by one timestep. Public (not just the _physics_process
## hook) so tests can call it directly without needing a live engine loop.
##
## A no-op while a real GameState exists and isn't PLAYING (frozen during
## MENU/DEAD). Under headless `-s` tests, get_game_state() is always null,
## so this check never triggers and step() behaves exactly as it did before
## Milestone 11 - existing tests are unaffected.
func step(delta: float) -> void:
	_ensure_start_position_captured()
	_ensure_game_state_connected()

	var game_state = get_game_state()
	if game_state and not game_state.is_playing():
		return

	scroll_manager.advance(delta)
	var player := get_player()
	if player:
		player.velocity.x = scroll_manager.scroll_speed

		if spawner.should_spawn(scroll_manager.distance_traveled):
			_spawn_obstacle()
		_despawn_old_obstacles()

		if game_state:
			var died_this_frame: bool = CollisionSystemScript.check_obstacles(player.position, player.radius, gather_obstacles(), game_state)
			if died_this_frame:
				high_score.record_score(get_current_score())

func _physics_process(delta: float) -> void:
	step(delta)

## Pure: does this input event represent a "tap" (touch-down or left-click)?
## Separated from _unhandled_input so it's testable without any tree/
## GameState context, the same way scripts/player/breathing_controller.gd
## keeps its input-type checks out of the untestable engine-callback path.
static func is_tap_event(event: InputEvent) -> bool:
	if event is InputEventScreenTouch and event.pressed:
		return true
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		return true
	return false

## Tapping while not playing starts (MENU) or restarts (DEAD) the run -
## both are already-legal GameState transitions to PLAYING.
func _unhandled_input(event: InputEvent) -> void:
	var game_state = get_game_state()
	if not game_state or game_state.is_playing():
		return
	if is_tap_event(event):
		game_state.transition_to(GameStateScript.State.PLAYING)
