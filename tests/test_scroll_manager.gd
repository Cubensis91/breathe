extends SceneTree

## Headless test for scripts/world/scroll_manager.gd.
## Run via: godot4 --headless -s res://tests/test_scroll_manager.gd

const ScrollManagerScript = preload("res://scripts/world/scroll_manager.gd")

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
	var m = ScrollManagerScript.new()

	_check(_approx(m.scroll_speed, m.difficulty.base_speed), "initial scroll_speed matches the difficulty curve's base_speed")
	_check(m.distance_traveled == 0.0, "initial distance_traveled is 0")

	var speed_before: float = m.scroll_speed
	m.advance(1.0)
	_check(_approx(m.distance_traveled, speed_before * 1.0), "advance() moves distance_traveled by the speed in effect *before* this step")
	_check(_approx(m.scroll_speed, m.difficulty.compute_scroll_speed(m.distance_traveled)), "scroll_speed after advance() matches the difficulty curve at the new distance")

	# Repeated advances keep distance_traveled and scroll_speed self-consistent.
	for i in range(50):
		m.advance(1.0)
	_check(_approx(m.scroll_speed, m.difficulty.compute_scroll_speed(m.distance_traveled)), "scroll_speed stays self-consistent with the difficulty curve after many steps")
	_check(m.scroll_speed > speed_before, "scroll_speed has increased after 51 seconds of travel (difficulty ramped up)")
	_check(m.scroll_speed <= m.difficulty.max_speed, "scroll_speed never exceeds the difficulty curve's max_speed")

	print("test_scroll_manager: %d passed, %d failed" % [_passed, _failed])
	quit(1 if _failed > 0 else 0)
