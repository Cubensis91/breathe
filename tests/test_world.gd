extends SceneTree

## Headless test for scripts/world/world.gd and world.tscn.
## Run via: godot4 --headless -s res://tests/test_world.gd

const WorldScene = preload("res://scripts/world/world.tscn")
const WorldScript = preload("res://scripts/world/world.gd")
const PlayerScript = preload("res://scripts/player/player.gd")
const ObstacleScript = preload("res://scripts/world/obstacle.gd")

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

	# Milestone 8: World collects its Obstacle/MovingObstacle children.
	var obstacles := world.gather_obstacles()
	_check(obstacles.size() == 2, "world.tscn has 2 obstacle children (Obstacle1, MovingObstacle1)")

	var found_static := false
	var found_moving := false
	for o in obstacles:
		_check(o.has("position") and o.has("radius"), "each gathered obstacle has position and radius keys")
		if _approx(o.position.x, 700.0) and _approx(o.position.y, 550.0):
			found_static = true
		if _approx(o.position.x, 1100.0) and _approx(o.position.y, 640.0):
			found_moving = true
	_check(found_static, "gathered obstacles include Obstacle1 at its scene position (700, 550)")
	_check(found_moving, "gathered obstacles include MovingObstacle1 at its initial position (1100, 640)")
	# obstacles.size() == 2 (checked above) already confirms Player and the
	# 4 Marker Polygon2Ds are correctly excluded (world.tscn has 7 children
	# total: Player, 4 Markers, Obstacle1, MovingObstacle1).

	# get_game_state() returns null outside a live project boot (no autoload
	# context under -s script mode) - step() must degrade gracefully, not crash.
	_check(world.get_game_state() == null, "get_game_state() is null under -s script mode (no autoload context)")
	world.step(0.1)  # must not crash even though get_game_state() is null

	world.free()

	print("test_world: %d passed, %d failed" % [_passed, _failed])
	quit(1 if _failed > 0 else 0)
