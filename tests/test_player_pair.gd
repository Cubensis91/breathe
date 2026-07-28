extends SceneTree

## Headless test for scripts/player/player_pair.gd and player_pair.tscn.
## Run via: godot4 --headless -s res://tests/test_player_pair.gd

const PlayerPairScene = preload("res://scripts/player/player_pair.tscn")
const PlayerPairScript = preload("res://scripts/player/player_pair.gd")

var _passed := 0
var _failed := 0

func _check(condition: bool, description: String) -> void:
	if condition:
		_passed += 1
	else:
		_failed += 1
		print("FAIL: %s" % description)

func _initialize() -> void:
	# Scene wiring: instantiates cleanly with both entities, breathing, and bond present.
	var scene_instance = PlayerPairScene.instantiate()
	_check(scene_instance is Node2D, "player_pair.tscn instantiates as a Node2D")
	_check(scene_instance.velocity == Vector2.ZERO, "player_pair.tscn instance starts with zero velocity")

	var entity_a = scene_instance.get_entity_a()
	var entity_b = scene_instance.get_entity_b()
	var breathing = scene_instance.get_breathing()
	var bond = scene_instance.get_energy_bond()
	_check(entity_a != null, "player_pair.tscn instance finds its EntityA child")
	_check(entity_b != null, "player_pair.tscn instance finds its EntityB child")
	_check(breathing != null, "player_pair.tscn instance finds its BreathingController child")
	_check(bond != null, "player_pair.tscn instance finds its EnergyBond child")

	# Holding drives ascent (vertical velocity) exactly like the original
	# Player + BreathingController pairing (see test_player.gd), and now
	# also drives the shared OrbitController's angle/energy.
	breathing.set_holding(true)
	scene_instance.integrate_physics(0.1)
	_check(scene_instance.velocity.y < 0.0, "holding makes the pair rise, same ramp as the original Player")
	_check(scene_instance.orbit.angular_velocity > 0.0, "holding also drives the shared OrbitController's angular_velocity positive")
	_check(scene_instance.orbit.energy_level > 0.0, "holding raises the shared OrbitController's energy_level above 0")

	# Entities track the orbit's offsets each step, diametrically opposite.
	_check(entity_a.position.is_equal_approx(scene_instance.orbit.get_entity_a_offset()), "EntityA's local position matches OrbitController's offset after a step")
	_check(entity_b.position.is_equal_approx(scene_instance.orbit.get_entity_b_offset()), "EntityB's local position matches OrbitController's offset after a step")
	_check(entity_a.position.distance_to(entity_b.position) > 0.0, "the two entities are not on top of each other")

	# EnergyBond is driven by PlayerPair each step - read-only from its side
	# (see energy_bond.gd), so this only checks the wiring, not the
	# width/alpha math itself (that's test_energy_bond.gd's job).
	_check(bond.points.size() == 3, "PlayerPair wires EnergyBond.update() each step - bond has 3-point geometry")
	_check(bond.points[0].is_equal_approx(entity_a.position), "EnergyBond's first point matches EntityA's current local position")
	_check(bond.points[2].is_equal_approx(entity_b.position), "EnergyBond's last point matches EntityB's current local position")

	scene_instance.free()

	# Script logic in isolation (no scene tree, no children - matches
	# Player's Milestone 4 bare-instance convention).
	var pair = PlayerPairScript.new()
	_check(pair.position == Vector2.ZERO, "default position is origin")
	_check(pair.velocity == Vector2.ZERO, "default velocity is zero")
	_check(pair.get_breathing() == null, "a bare PlayerPair with no children has no BreathingController")
	_check(pair.get_entity_a() == null, "a bare PlayerPair with no children has no EntityA")
	_check(pair.get_entity_b() == null, "a bare PlayerPair with no children has no EntityB")

	# orbit is an owned field (not a child lookup), so it still advances
	# even with zero children present.
	pair.integrate_physics(0.1)
	_check(pair.orbit.angular_velocity < 0.0, "orbit still advances internally even with no scene children present")
	_check(pair.velocity == Vector2.ZERO, "with no BreathingController, vertical velocity is untouched")
	_check(pair.position == Vector2.ZERO, "with no BreathingController, position is untouched")

	pair.free()

	print("test_player_pair: %d passed, %d failed" % [_passed, _failed])
	quit(1 if _failed > 0 else 0)
