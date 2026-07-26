extends SceneTree

## Headless test for scripts/world/world.gd and world.tscn.
## Run via: godot4 --headless -s res://tests/test_world.gd

const WorldScene = preload("res://scripts/world/world.tscn")
const WorldScript = preload("res://scripts/world/world.gd")
const PlayerScript = preload("res://scripts/player/player.gd")

var _passed := 0
var _failed := 0

func _check(condition: bool, description: String) -> void:
	if condition:
		_passed += 1
	else:
		_failed += 1
		print("FAIL: %s" % description)

func _approx(a: float, b: float, eps: float = 0.5) -> bool:
	return abs(a - b) <= eps

func _initialize() -> void:
	var world := WorldScene.instantiate() as WorldScript
	_check(world != null, "world.tscn instantiates")

	var player := world.get_player()
	_check(player != null, "World finds its Player child via get_player()")
	_check(player is PlayerScript, "Player child is a Player instance")

	var start_x: float = player.position.x

	# Manually drive several physics steps - no live engine loop needed,
	# consistent with how test_player.gd exercises integrate_physics directly.
	var delta := 0.1
	var steps := 10
	for i in range(steps):
		world.step(delta)
		player.integrate_physics(delta)

	_check(_approx(player.velocity.x, world.scroll_manager.scroll_speed), "player.velocity.x tracks world scroll speed after stepping")

	var expected_distance: float = world.scroll_manager.scroll_speed * (delta * steps)
	_check(_approx(world.scroll_manager.distance_traveled, expected_distance), "scroll_manager accumulates distance correctly")
	_check(_approx(player.position.x, start_x + expected_distance), "player.position.x advances with world scroll")

	world.free()

	print("test_world: %d passed, %d failed" % [_passed, _failed])
	quit(1 if _failed > 0 else 0)
