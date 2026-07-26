extends SceneTree

## Headless test for scripts/audio/audio_settings.gd.
## Run via: godot4 --headless -s res://tests/test_audio_settings.gd
##
## Uses a throwaway user:// save path (unique per run) instead of the real
## save file, and deletes it afterward - mirrors tests/test_high_score.gd.

const AudioSettingsScript = preload("res://scripts/audio/audio_settings.gd")

var _passed := 0
var _failed := 0

func _check(condition: bool, description: String) -> void:
	if condition:
		_passed += 1
	else:
		_failed += 1
		print("FAIL: %s" % description)

func _initialize() -> void:
	var s = AudioSettingsScript.new()
	s.save_path = "user://test_audio_settings_%d.save" % Time.get_ticks_usec()

	_check(s.is_enabled() == true, "audio defaults to enabled when no save file exists yet")

	s.set_enabled(false)
	_check(s.is_enabled() == false, "set_enabled(false) persists")

	s.set_enabled(true)
	_check(s.is_enabled() == true, "set_enabled(true) persists")

	var new_value := s.toggle()
	_check(new_value == false, "toggle() returns the new (flipped) value")
	_check(s.is_enabled() == false, "toggle() persists the flipped value")

	s.toggle()
	_check(s.is_enabled() == true, "toggling twice returns to the original value")

	if FileAccess.file_exists(s.save_path):
		DirAccess.remove_absolute(s.save_path)
	_check(not FileAccess.file_exists(s.save_path), "test cleans up its throwaway save file")

	print("test_audio_settings: %d passed, %d failed" % [_passed, _failed])
	quit(1 if _failed > 0 else 0)
