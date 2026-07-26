extends SceneTree

## Headless test for scripts/player/player.gd and player.tscn.
## Run via: godot4 --headless -s res://tests/test_player.gd

const PlayerScene = preload("res://scripts/player/player.tscn")
const PlayerScript = preload("res://scripts/player/player.gd")

var _passed := 0
var _failed := 0

func _check(condition: bool, description: String) -> void:
	if condition:
		_passed += 1
	else:
		_failed += 1
		print("FAIL: %s" % description)

func _initialize() -> void:
	# Scene wiring: instantiates cleanly as an Area2D with zero starting velocity.
	var scene_instance = PlayerScene.instantiate()
	_check(scene_instance is Area2D, "player.tscn instantiates as an Area2D")
	_check(scene_instance.velocity == Vector2.ZERO, "player.tscn instance starts with zero velocity")
	scene_instance.free()

	# Script logic in isolation (no scene tree needed).
	var p = PlayerScript.new()
	_check(p.position == Vector2.ZERO, "default position is origin")
	_check(p.velocity == Vector2.ZERO, "default velocity is zero")

	p.velocity = Vector2(0, -200)
	p.integrate_physics(0.5)
	_check(p.position.is_equal_approx(Vector2(0, -100)), "integrate_physics moves position by velocity * delta")

	p.velocity = Vector2(50, 10)
	p.integrate_physics(1.0)
	_check(p.position.is_equal_approx(Vector2(50, -90)), "integrate_physics accumulates across multiple calls")

	p.free()

	print("test_player: %d passed, %d failed" % [_passed, _failed])
	quit(1 if _failed > 0 else 0)
