extends SceneTree

## Headless test for scripts/world/obstacle.gd and obstacle.tscn.
## Run via: godot4 --headless -s res://tests/test_obstacle.gd

const ObstacleScene = preload("res://scripts/world/obstacle.tscn")
const ObstacleScript = preload("res://scripts/world/obstacle.gd")

var _passed := 0
var _failed := 0

func _check(condition: bool, description: String) -> void:
	if condition:
		_passed += 1
	else:
		_failed += 1
		print("FAIL: %s" % description)

func _initialize() -> void:
	var scene_instance = ObstacleScene.instantiate()
	_check(scene_instance is Node2D, "obstacle.tscn instantiates as a Node2D")
	_check(scene_instance.radius == 24.0, "obstacle.tscn instance has the default radius")
	scene_instance.free()

	var o = ObstacleScript.new()
	_check(o.radius == 24.0, "default Obstacle radius is 24.0")
	_check(o.position == Vector2.ZERO, "default Obstacle position is origin - static, no movement behavior")

	o.radius = 40.0
	_check(o.radius == 40.0, "radius is overridable")

	o.free()

	print("test_obstacle: %d passed, %d failed" % [_passed, _failed])
	quit(1 if _failed > 0 else 0)
