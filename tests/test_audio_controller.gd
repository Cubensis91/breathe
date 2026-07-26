extends SceneTree

## Headless test for scripts/audio/audio_controller.gd and audio_controller.tscn.
## Run via: godot4 --headless -s res://tests/test_audio_controller.gd
##
## No real audio streams are assigned yet (see docs/current_status.md), so
## this test focuses on what's actually verifiable right now: the scene
## has the expected AudioStreamPlayer children, and every routing method
## is safe to call - with settings on or off, with or without streams -
## without crashing. Whether anything audible happens is a PC/Android
## concern for once real audio assets exist.

const AudioControllerScene = preload("res://scripts/audio/audio_controller.tscn")
const AudioControllerScript = preload("res://scripts/audio/audio_controller.gd")

var _passed := 0
var _failed := 0

func _check(condition: bool, description: String) -> void:
	if condition:
		_passed += 1
	else:
		_failed += 1
		print("FAIL: %s" % description)

func _initialize() -> void:
	var a := AudioControllerScene.instantiate() as AudioControllerScript
	_check(a != null, "audio_controller.tscn instantiates")

	for expected_name in ["Inhale", "Collision", "GameOver", "Music"]:
		var player := a.get_node_or_null(expected_name)
		_check(player is AudioStreamPlayer, "audio_controller.tscn has an AudioStreamPlayer named %s" % expected_name)
		_check(player.stream == null, "%s has no stream assigned yet (placeholder territory)" % expected_name)

	# Safe to call with audio enabled (the default) even with no streams.
	_check(a.settings.is_enabled(), "AudioController's settings default to enabled")
	a.play_inhale()
	a.play_collision()
	a.play_game_over()
	a.start_music()
	a.stop_music()
	_check(true, "all routing methods are safe to call with no streams assigned")

	# Safe to call with audio disabled too.
	a.settings.save_path = "user://test_audio_controller_settings_%d.save" % Time.get_ticks_usec()
	a.settings.set_enabled(false)
	a.play_inhale()
	a.play_collision()
	a.play_game_over()
	a.start_music()
	_check(true, "all routing methods are safe to call with audio disabled")

	if FileAccess.file_exists(a.settings.save_path):
		DirAccess.remove_absolute(a.settings.save_path)

	a.free()

	print("test_audio_controller: %d passed, %d failed" % [_passed, _failed])
	quit(1 if _failed > 0 else 0)
