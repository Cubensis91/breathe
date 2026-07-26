extends SceneTree

## Headless test for scripts/world/world.gd and world.tscn.
## Run via: godot4 --headless -s res://tests/test_world.gd

const WorldScene = preload("res://scripts/world/world.tscn")
const WorldScript = preload("res://scripts/world/world.gd")
const PlayerScript = preload("res://scripts/player/player.gd")
const GameStateScript = preload("res://scripts/core/game_state.gd")

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

	_check(world.gather_obstacles().size() == 0, "world.tscn starts with no obstacles - spawning is fully procedural (Milestone 9)")

	# Manually drive several physics steps - no live engine loop needed,
	# consistent with how test_player.gd exercises integrate_physics directly.
	var delta := 0.1
	var steps := 10
	for i in range(steps):
		world.step(delta)
		player.integrate_physics(delta)

	_check(_approx(player.velocity.x, world.scroll_manager.scroll_speed), "player.velocity.x tracks world scroll speed after stepping")
	_check(world.scroll_manager.distance_traveled > 0.0, "scroll_manager has accumulated some distance")
	_check(player.position.x > start_x, "player.position.x has advanced with world scroll")
	_check(
		_approx(world.scroll_manager.scroll_speed, world.scroll_manager.difficulty.compute_scroll_speed(world.scroll_manager.distance_traveled)),
		"scroll_speed stays consistent with the difficulty curve (Milestone 9) after stepping"
	)

	# Milestone 9: fast-forward with larger steps to comfortably cross the
	# first spawn threshold (~400px of distance) without an excessive
	# number of iterations.
	for i in range(5):
		world.step(1.0)
		player.integrate_physics(1.0)
	var obstacles_after_spawn := world.gather_obstacles()
	_check(obstacles_after_spawn.size() > 0, "at least one obstacle has spawned after enough distance has been traveled")
	for o in obstacles_after_spawn:
		_check(o.has("position") and o.has("radius"), "each spawned obstacle has position and radius keys")

	# Keep going long enough that early obstacles fall far behind the player
	# and get despawned, while new ones keep spawning - child count should
	# stay bounded rather than growing without limit over a long run.
	for i in range(60):
		world.step(1.0)
		player.integrate_physics(1.0)
	_check(world.get_children().size() < 30, "obstacle count stays bounded over a long run (despawn is working, not just spawn)")
	_check(world.gather_obstacles().size() > 0, "obstacles still exist near the player after a long run")

	# get_game_state() returns null outside a live project boot (no autoload
	# context under -s script mode) - step() must degrade gracefully, not crash.
	_check(world.get_game_state() == null, "get_game_state() is null under -s script mode (no autoload context)")
	world.step(0.1)  # must not crash even though get_game_state() is null

	world.free()

	# Milestone 11: GameState integration.
	#
	# get_game_state()'s get_node_or_null("/root/GameState") fundamentally
	# cannot resolve under `-s` script mode, even with a hand-built live
	# tree - confirmed by direct probe: even this SceneTree's own `root`
	# reports "not in a scene tree" for get_path()/absolute NodePath
	# resolution here. So get_game_state(), and anything gated purely on
	# it (the freeze-while-not-playing check, and the tap-detection
	# branch's `if not game_state` guard), are only exercised for real once
	# a genuine project boot provides the actual autoload - manual/PC
	# testing territory, same accepted limit as the Milestone 8-10
	# GameState-gated code paths.
	#
	# What *is* testable headlessly: reset_session() and
	# _on_game_state_changed() take no GameState/tree dependency at all -
	# they're plain method calls - and is_tap_event() is a pure function.
	var world2 := WorldScene.instantiate() as WorldScript
	var player2 := world2.get_player()
	var start_position2: Vector2 = player2.position

	# Make some session progress to have something to reset.
	for i in range(5):
		world2.step(1.0)
		player2.integrate_physics(1.0)
	_check(world2.scroll_manager.distance_traveled > 0.0, "session has made some progress before resetting")
	_check(player2.position.x > start_position2.x, "player has moved before resetting")

	world2._on_game_state_changed(GameStateScript.State.PLAYING, GameStateScript.State.DEAD)
	_check(world2.scroll_manager.distance_traveled > 0.0, "transitioning to a non-PLAYING state does not reset the session")

	world2._on_game_state_changed(GameStateScript.State.MENU, GameStateScript.State.PLAYING)
	_check(world2.scroll_manager.distance_traveled == 0.0, "transitioning to PLAYING resets distance_traveled to 0")
	_check(player2.position == start_position2, "transitioning to PLAYING resets the player's position")
	_check(player2.velocity == Vector2.ZERO, "transitioning to PLAYING resets the player's velocity")
	_check(world2.gather_obstacles().size() == 0, "transitioning to PLAYING clears any obstacles that had spawned")

	world2.free()

	_check(WorldScript.is_tap_event(_make_touch(true)) == true, "a pressed screen touch is a tap")
	_check(WorldScript.is_tap_event(_make_touch(false)) == false, "a released screen touch is not a tap")
	_check(WorldScript.is_tap_event(_make_mouse_click(MOUSE_BUTTON_LEFT, true)) == true, "a left mouse press is a tap")
	_check(WorldScript.is_tap_event(_make_mouse_click(MOUSE_BUTTON_LEFT, false)) == false, "a left mouse release is not a tap")
	_check(WorldScript.is_tap_event(_make_mouse_click(MOUSE_BUTTON_RIGHT, true)) == false, "a right mouse press is not a tap")

	print("test_world: %d passed, %d failed" % [_passed, _failed])
	quit(1 if _failed > 0 else 0)

func _make_touch(pressed: bool) -> InputEventScreenTouch:
	var e := InputEventScreenTouch.new()
	e.pressed = pressed
	return e

func _make_mouse_click(button_index: int, pressed: bool) -> InputEventMouseButton:
	var e := InputEventMouseButton.new()
	e.button_index = button_index
	e.pressed = pressed
	return e
