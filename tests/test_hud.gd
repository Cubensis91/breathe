extends SceneTree

## Headless test for scripts/ui/hud.gd and hud.tscn.
## Run via: godot4 --headless -s res://tests/test_hud.gd

const HudScene = preload("res://scripts/ui/hud.tscn")
const HudScript = preload("res://scripts/ui/hud.gd")
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
	var scene_instance = HudScene.instantiate()
	_check(scene_instance is CanvasLayer, "hud.tscn instantiates as a CanvasLayer")
	_check(scene_instance.get_node_or_null("Label") != null, "hud.tscn has a Label child")
	scene_instance.free()

	var menu_text := HudScript.compute_display_text(GameStateScript.State.MENU, 0, 42)
	_check(menu_text.contains("Tap to start"), "MENU text prompts the player to start")

	var playing_text := HudScript.compute_display_text(GameStateScript.State.PLAYING, 17, 42)
	_check(playing_text.contains("17"), "PLAYING text shows the current score")
	_check(not playing_text.contains("Tap"), "PLAYING text has no start/restart prompt")

	var dead_text := HudScript.compute_display_text(GameStateScript.State.DEAD, 17, 42)
	_check(dead_text.contains("17"), "DEAD text shows the final score")
	_check(dead_text.contains("42"), "DEAD text shows the high score")
	_check(dead_text.contains("Tap to restart"), "DEAD text prompts the player to restart")

	print("test_hud: %d passed, %d failed" % [_passed, _failed])
	quit(1 if _failed > 0 else 0)
