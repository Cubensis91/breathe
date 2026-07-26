extends SceneTree

## Headless test for scripts/world/difficulty_curve.gd.
## Run via: godot4 --headless -s res://tests/test_difficulty_curve.gd

const DifficultyCurveScript = preload("res://scripts/world/difficulty_curve.gd")

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
	var d = DifficultyCurveScript.new()

	_check(_approx(d.compute_scroll_speed(0.0), d.base_speed), "speed at distance 0 is base_speed")

	var expected_mid: float = d.base_speed + 1000.0 * d.ramp_rate
	_check(_approx(d.compute_scroll_speed(1000.0), expected_mid), "speed ramps linearly with distance")
	_check(expected_mid < d.max_speed, "sanity: the mid-distance sample used above is below max_speed")

	_check(_approx(d.compute_scroll_speed(1000000000.0), d.max_speed), "speed is capped at max_speed for huge distance")

	# Monotonic: speed never decreases as distance increases.
	_check(d.compute_scroll_speed(500.0) <= d.compute_scroll_speed(1500.0), "speed is monotonically non-decreasing with distance")

	print("test_difficulty_curve: %d passed, %d failed" % [_passed, _failed])
	quit(1 if _failed > 0 else 0)
