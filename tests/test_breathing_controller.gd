extends SceneTree

## Headless test for scripts/player/breathing_controller.gd.
## Run via: godot4 --headless -s res://tests/test_breathing_controller.gd

const BreathingControllerScript = preload("res://scripts/player/breathing_controller.gd")

var _passed := 0
var _failed := 0

func _check(condition: bool, description: String) -> void:
	if condition:
		_passed += 1
	else:
		_failed += 1
		print("FAIL: %s" % description)

func _approx(a: float, b: float, eps: float = 0.001) -> bool:
	return abs(a - b) <= eps

func _initialize() -> void:
	var b = BreathingControllerScript.new()

	_check(b.is_holding == false, "default is_holding is false")

	# Released: accelerates downward (positive Y), clamped at max_fall_speed.
	var v := 0.0
	v = b.compute_velocity_y(v, 0.1)
	_check(_approx(v, 90.0), "released: one 0.1s step accelerates toward positive (descend)")

	v = 0.0
	v = b.compute_velocity_y(v, 1.0)
	_check(_approx(v, b.max_fall_speed), "released: large delta clamps at max_fall_speed rather than overshooting")

	# Holding: accelerates upward (negative Y), clamped at max_rise_speed.
	b.set_holding(true)
	_check(b.is_holding == true, "set_holding(true) updates is_holding")

	v = 0.0
	v = b.compute_velocity_y(v, 0.1)
	_check(_approx(v, -90.0), "holding: one 0.1s step accelerates toward negative (rise)")

	# Gradual acceleration toward the clamp over several small steps.
	v = 0.0
	for i in range(5):
		v = b.compute_velocity_y(v, 0.1)
	_check(_approx(v, -b.max_rise_speed), "holding: repeated steps reach max_rise_speed without overshoot")

	# Rapid release mid-rise should immediately reverse direction (responsiveness).
	b.set_holding(false)
	var v_after_release := b.compute_velocity_y(v, 0.1)
	_check(v_after_release > v, "releasing while rising immediately starts decelerating/reversing")

	# Rapid re-hold should immediately reverse again.
	b.set_holding(true)
	var v_after_rehold := b.compute_velocity_y(v_after_release, 0.1)
	_check(v_after_rehold < v_after_release, "re-holding immediately starts rising again")

	b.free()

	print("test_breathing_controller: %d passed, %d failed" % [_passed, _failed])
	quit(1 if _failed > 0 else 0)
