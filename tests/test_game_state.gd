extends SceneTree

## Headless test for scripts/core/game_state.gd.
## Run directly (not via the autoload) so it's isolated from the rest of the
## project: `godot4 --headless -s res://tests/test_game_state.gd`.
## Exits with code 0 on success, 1 on any assertion failure.

const GameStateScript = preload("res://scripts/core/game_state.gd")

var _passed := 0
var _failed := 0

func _check(condition: bool, description: String) -> void:
	if condition:
		_passed += 1
	else:
		_failed += 1
		print("FAIL: %s" % description)

func _initialize() -> void:
	var gs = GameStateScript.new()

	_check(gs.current_state == gs.State.MENU, "default state is MENU")
	_check(gs.is_menu() and not gs.is_playing() and not gs.is_dead(), "is_menu()/is_playing()/is_dead() consistent with default state")

	var signal_calls := []
	gs.state_changed.connect(func(prev, cur): signal_calls.append([prev, cur]))

	_check(gs.transition_to(gs.State.PLAYING) == true, "MENU -> PLAYING is allowed")
	_check(gs.is_playing(), "state is PLAYING after legal transition")
	_check(signal_calls.size() == 1 and signal_calls[0] == [gs.State.MENU, gs.State.PLAYING], "state_changed emitted once with correct args")

	_check(gs.transition_to(gs.State.MENU) == false, "PLAYING -> MENU is rejected (not an allowed transition)")
	_check(gs.is_playing(), "state unchanged after rejected transition")
	_check(signal_calls.size() == 1, "state_changed not emitted for rejected transition")

	_check(gs.transition_to(gs.State.PLAYING) == false, "PLAYING -> PLAYING is a no-op")
	_check(signal_calls.size() == 1, "state_changed not emitted for no-op transition")

	_check(gs.transition_to(gs.State.DEAD) == true, "PLAYING -> DEAD is allowed")
	_check(gs.is_dead(), "state is DEAD after legal transition")

	_check(gs.transition_to(gs.State.PLAYING) == true, "DEAD -> PLAYING (restart) is allowed")
	_check(gs.is_playing(), "state is PLAYING after restart transition")

	var gs2 = GameStateScript.new()
	gs2.transition_to(gs2.State.PLAYING)
	gs2.transition_to(gs2.State.DEAD)
	_check(gs2.transition_to(gs2.State.MENU) == true, "DEAD -> MENU is allowed")

	# MENU -> DEAD is the one (from, to) pair not yet covered above - every
	# other entry/non-entry in _ALLOWED_TRANSITIONS now has a direct test.
	var gs3 = GameStateScript.new()
	_check(gs3.transition_to(gs3.State.DEAD) == false, "MENU -> DEAD is rejected (not an allowed transition)")
	_check(gs3.is_menu(), "state unchanged after rejected MENU -> DEAD transition")

	gs.free()
	gs2.free()
	gs3.free()

	print("test_game_state: %d passed, %d failed" % [_passed, _failed])
	quit(1 if _failed > 0 else 0)
