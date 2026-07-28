extends SceneTree

## Headless test for scripts/player/energy_bond.gd.
## Run via: godot4 --headless -s res://tests/test_energy_bond.gd

const EnergyBondScript = preload("res://scripts/player/energy_bond.gd")

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
	# --- compute_points(): pure geometry, no instance/tree needed ---
	var a := Vector2(-10, 0)
	var b := Vector2(10, 0)

	var pts_zero := EnergyBondScript.compute_points(a, b, 0.0, 20.0)
	_check(pts_zero.size() == 3, "compute_points returns 3 points (A, midpoint, B)")
	_check(_approx_vec(pts_zero[0], a), "first point is entity A's position")
	_check(_approx_vec(pts_zero[2], b), "last point is entity B's position")
	_check(_approx_vec(pts_zero[1], (a + b) / 2.0), "at energy_level 0, the midpoint has no bow")

	var pts_full := EnergyBondScript.compute_points(a, b, 1.0, 20.0)
	_check(not _approx_vec(pts_full[1], (a + b) / 2.0), "at energy_level 1, the midpoint bows away from the straight line")
	_check(_approx(pts_full[1].distance_to((a + b) / 2.0), 20.0), "bow distance matches curvature_amplitude at full energy")

	var pts_half := EnergyBondScript.compute_points(a, b, 0.5, 20.0)
	_check(_approx(pts_half[1].distance_to((a + b) / 2.0), 10.0), "bow distance scales linearly with energy_level")

	# Degenerate case: coincident entities shouldn't produce NaN/inf.
	var pts_degenerate := EnergyBondScript.compute_points(a, a, 1.0, 20.0)
	_check(_approx_vec(pts_degenerate[1], a), "coincident entity positions produce a non-degenerate midpoint (no NaN)")

	# --- update(): drives width/color alongside points on a live instance ---
	var bond := EnergyBondScript.new()
	bond.min_width = 3.0
	bond.max_width = 10.0
	bond.min_alpha = 0.35
	bond.max_alpha = 1.0

	bond.update(a, b, 0.0)
	_check(_approx(bond.width, 3.0), "update() at energy 0 sets width to min_width")
	_check(_approx(bond.default_color.a, 0.35), "update() at energy 0 sets alpha to min_alpha")

	bond.update(a, b, 1.0)
	_check(_approx(bond.width, 10.0), "update() at energy 1 sets width to max_width")
	_check(_approx(bond.default_color.a, 1.0), "update() at energy 1 sets alpha to max_alpha")
	_check(_approx_vec(bond.points[0], a), "update() sets the first rendered point to entity A's position")
	_check(_approx_vec(bond.points[2], b), "update() sets the last rendered point to entity B's position")

	bond.free()

	print("test_energy_bond: %d passed, %d failed" % [_passed, _failed])
	quit(1 if _failed > 0 else 0)
