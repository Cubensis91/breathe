extends SceneTree

## Headless test for scripts/systems/collision_system.gd.
## Run via: godot4 --headless -s res://tests/test_collision_system.gd

const CollisionSystemScript = preload("res://scripts/systems/collision_system.gd")
const GameStateScript = preload("res://scripts/core/game_state.gd")

var _passed := 0
var _failed := 0

func _check(condition: bool, description: String) -> void:
	if condition:
		_passed += 1
	else:
		_failed += 1
		print("FAIL: %s" % description)

func _initialize() -> void:
	# Pure geometry.
	_check(
		CollisionSystemScript.circles_overlap(Vector2(0, 0), 10.0, Vector2(15, 0), 10.0) == true,
		"overlapping circles (distance 15 < combined radius 20) detected"
	)
	_check(
		CollisionSystemScript.circles_overlap(Vector2(0, 0), 10.0, Vector2(25, 0), 10.0) == false,
		"non-overlapping circles (distance 25 > combined radius 20) not detected"
	)
	_check(
		CollisionSystemScript.circles_overlap(Vector2(0, 0), 10.0, Vector2(20, 0), 10.0) == true,
		"exactly-touching circles (distance == combined radius) count as overlapping"
	)

	# Orchestration: check_obstacles() + an isolated GameState instance
	# (not the autoload - see test_game_state.gd for why).
	var gs = GameStateScript.new()
	gs.transition_to(gs.State.PLAYING)

	var far_obstacles: Array = [{"position": Vector2(500, 0), "radius": 20.0}]
	var triggered_far: bool = CollisionSystemScript.check_obstacles(Vector2(0, 0), 16.0, far_obstacles, gs)
	_check(triggered_far == false, "far-away obstacle does not trigger death")
	_check(gs.is_playing(), "state remains PLAYING when nothing overlaps")

	var near_obstacles: Array = [
		{"position": Vector2(500, 0), "radius": 20.0},
		{"position": Vector2(10, 0), "radius": 20.0},
	]
	var triggered_near: bool = CollisionSystemScript.check_obstacles(Vector2(0, 0), 16.0, near_obstacles, gs)
	_check(triggered_near == true, "overlapping obstacle triggers death")
	_check(gs.is_dead(), "state transitions to DEAD on collision")

	# Once dead, further checks are no-ops (check_obstacles only acts while PLAYING).
	var triggered_again: bool = CollisionSystemScript.check_obstacles(Vector2(0, 0), 16.0, near_obstacles, gs)
	_check(triggered_again == false, "check_obstacles is a no-op once no longer PLAYING")

	gs.free()

	print("test_collision_system: %d passed, %d failed" % [_passed, _failed])
	quit(1 if _failed > 0 else 0)
