extends SceneTree

## Headless test for scripts/world/moving_obstacle.gd and moving_obstacle.tscn.
## Run via: godot4 --headless -s res://tests/test_moving_obstacle.gd

const MovingObstacleScene = preload("res://scripts/world/moving_obstacle.tscn")
const MovingObstacleScript = preload("res://scripts/world/moving_obstacle.gd")
const ObstacleScript = preload("res://scripts/world/obstacle.gd")

var _passed := 0
var _failed := 0

func _check(condition: bool, description: String) -> void:
	if condition:
		_passed += 1
	else:
		_failed += 1
		print("FAIL: %s" % description)

func _approx(a: float, b: float, eps: float = 0.01) -> bool:
	return abs(a - b) <= eps

func _initialize() -> void:
	var scene_instance = MovingObstacleScene.instantiate()
	_check(scene_instance is ObstacleScript, "moving_obstacle.tscn instantiates as an Obstacle (inherits radius)")
	_check(scene_instance is MovingObstacleScript, "moving_obstacle.tscn instantiates as a MovingObstacle")
	scene_instance.free()

	var m = MovingObstacleScript.new()
	m.origin_y = 500.0
	m.amplitude = 100.0
	m.period = 2.0

	# Pure sine math, independent of any node state.
	_check(_approx(m.compute_offset_y(0.0), 0.0), "offset at t=0 is 0")
	_check(_approx(m.compute_offset_y(m.period * 0.25), m.amplitude), "offset at quarter-period is +amplitude")
	_check(_approx(m.compute_offset_y(m.period * 0.5), 0.0), "offset at half-period is back to 0")
	_check(_approx(m.compute_offset_y(m.period * 0.75), -m.amplitude), "offset at three-quarter-period is -amplitude")

	# advance() applies the offset relative to origin_y onto position.y.
	m.position.y = m.origin_y
	m.advance(m.period * 0.25)
	_check(_approx(m.position.y, m.origin_y + m.amplitude), "advance() moves position.y to origin_y + amplitude at quarter-period")

	m.advance(m.period * 0.25)
	_check(_approx(m.position.y, m.origin_y), "advance() accumulates elapsed time correctly (back to origin_y at half-period)")

	m.free()

	print("test_moving_obstacle: %d passed, %d failed" % [_passed, _failed])
	quit(1 if _failed > 0 else 0)
