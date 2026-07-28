extends SceneTree

## Headless test for scripts/player/orbit_controller.gd.
## Run via: godot4 --headless -s res://tests/test_orbit_controller.gd

const OrbitControllerScript = preload("res://scripts/player/orbit_controller.gd")

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

func _approx_vec(a: Vector2, b: Vector2, eps: float = 0.001) -> bool:
	return a.distance_to(b) <= eps

func _initialize() -> void:
	var o = OrbitControllerScript.new()

	_check(o.angle == 0.0, "default angle is 0")
	_check(o.angular_velocity == 0.0, "default angular_velocity is 0")
	_check(o.energy_level == 0.0, "default energy_level is 0")

	# --- compute_angular_velocity: ramps toward +/- max_angular_speed ---
	var av := 0.0
	av = o.compute_angular_velocity(av, true, 100.0)
	_check(_approx(av, o.max_angular_speed), "holding: large delta clamps at +max_angular_speed rather than overshooting")

	av = 0.0
	av = o.compute_angular_velocity(av, false, 100.0)
	_check(_approx(av, -o.max_angular_speed), "released: large delta clamps at -max_angular_speed rather than overshooting")

	# Rapid hold/release reverses direction immediately (responsiveness).
	av = o.max_angular_speed
	var av_after_release := o.compute_angular_velocity(av, false, 0.01)
	_check(av_after_release < av, "releasing while turning positive immediately starts reversing")

	# --- compute_energy_level: ramps toward 1.0 (hold) / 0.0 (release), clamped ---
	var e := 0.0
	e = o.compute_energy_level(e, true, 100.0)
	_check(_approx(e, 1.0), "holding: large delta clamps energy_level at 1.0, not beyond")

	e = 1.0
	e = o.compute_energy_level(e, false, 100.0)
	_check(_approx(e, 0.0), "released: large delta clamps energy_level at 0.0, not below")

	e = 0.0
	e = o.compute_energy_level(e, true, 0.05)
	_check(e > 0.0 and e < 1.0, "holding: small delta produces a partial ramp, not an instant jump")

	# --- advance(): integrates angle/angular_velocity/energy_level together ---
	var angle_before: float = o.angle
	o.advance(0.1, true)
	_check(o.angular_velocity > 0.0, "advance() while holding produces positive angular_velocity")
	_check(o.angle > angle_before, "advance() while holding increases angle (using the post-ramp angular_velocity)")
	_check(o.energy_level > 0.0, "advance() while holding raises energy_level above 0")

	for i in range(50):
		o.advance(0.1, true)
	_check(_approx(o.angular_velocity, o.max_angular_speed), "angular_velocity stays clamped at max_angular_speed after many holding steps")
	_check(_approx(o.energy_level, 1.0), "energy_level stays clamped at 1.0 after many holding steps")

	for i in range(50):
		o.advance(0.1, false)
	_check(_approx(o.angular_velocity, -o.max_angular_speed), "angular_velocity reverses to -max_angular_speed after many released steps")
	_check(_approx(o.energy_level, 0.0), "energy_level falls back to 0.0 after many released steps")

	# --- get_entity_offset / get_entity_a_offset / get_entity_b_offset ---
	var o2 = OrbitControllerScript.new()
	o2.angle = 0.0
	_check(_approx_vec(o2.get_entity_a_offset(), Vector2(o2.radius, 0.0)), "at angle 0, Entity A offset points along +X at distance radius")
	_check(_approx_vec(o2.get_entity_b_offset(), Vector2(-o2.radius, 0.0)), "at angle 0, Entity B offset points along -X at distance radius")
	_check(_approx_vec(o2.get_entity_a_offset() + o2.get_entity_b_offset(), Vector2.ZERO), "entities remain diametrically opposite around the shared center")
	_check(_approx(o2.get_entity_a_offset().length(), o2.radius), "Entity A stays exactly radius distance from center")

	o2.angle = PI / 2.0
	_check(_approx_vec(o2.get_entity_a_offset(), Vector2(0.0, o2.radius)), "at angle PI/2, Entity A offset points along +Y")

	print("test_orbit_controller: %d passed, %d failed" % [_passed, _failed])
	quit(1 if _failed > 0 else 0)
