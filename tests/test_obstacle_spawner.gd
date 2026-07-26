extends SceneTree

## Headless test for scripts/world/obstacle_spawner.gd.
## Run via: godot4 --headless -s res://tests/test_obstacle_spawner.gd

const ObstacleSpawnerScript = preload("res://scripts/world/obstacle_spawner.gd")

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
	var s = ObstacleSpawnerScript.new()

	_check(s.should_spawn(0.0) == false, "does not spawn before the first threshold")
	_check(s.should_spawn(399.0) == false, "does not spawn just before the threshold")
	_check(s.should_spawn(400.0) == true, "spawns exactly at the threshold")

	var expected_next: float = 400.0 + s.compute_interval(400.0)
	_check(_approx(s.next_spawn_distance, expected_next), "next_spawn_distance advances by the current interval")
	_check(s.should_spawn(expected_next - 1.0) == false, "does not spawn again before the new threshold")
	_check(s.should_spawn(expected_next) == true, "spawns again at the new threshold")

	# Interval shrinks with distance but is clamped at min_interval.
	_check(_approx(s.compute_interval(0.0), s.spawn_interval), "interval at distance 0 equals base spawn_interval")
	_check(_approx(s.compute_interval(1000000.0), s.min_interval), "interval is clamped to min_interval at huge distance")
	_check(s.compute_interval(500.0) >= s.compute_interval(5000.0), "interval is monotonically non-increasing with distance")

	print("test_obstacle_spawner: %d passed, %d failed" % [_passed, _failed])
	quit(1 if _failed > 0 else 0)
