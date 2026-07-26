extends SceneTree

## Headless test for scripts/systems/high_score.gd.
## Run via: godot4 --headless -s res://tests/test_high_score.gd
##
## Uses a throwaway user:// save path (unique per run) instead of the real
## save file, and deletes it afterward - doesn't touch or depend on any
## real persisted high score.

const HighScorePersistenceScript = preload("res://scripts/systems/high_score.gd")

var _passed := 0
var _failed := 0

func _check(condition: bool, description: String) -> void:
	if condition:
		_passed += 1
	else:
		_failed += 1
		print("FAIL: %s" % description)

func _initialize() -> void:
	var h = HighScorePersistenceScript.new()
	h.save_path = "user://test_high_score_%d.save" % Time.get_ticks_usec()

	_check(h.load_high_score() == 0, "load_high_score() returns 0 when no save file exists yet")

	_check(h.record_score(50) == true, "the first score is always a new record")
	_check(h.load_high_score() == 50, "load_high_score() reflects the just-saved record")

	_check(h.record_score(30) == false, "a lower score is not a new record")
	_check(h.load_high_score() == 50, "high score is unchanged after a lower attempt")

	_check(h.record_score(100) == true, "a higher score is a new record")
	_check(h.load_high_score() == 100, "high score updates to the new record")

	_check(h.record_score(100) == false, "an equal score does not count as a new record (must exceed, not match)")
	_check(h.load_high_score() == 100, "high score is unchanged after an equal attempt")

	if FileAccess.file_exists(h.save_path):
		DirAccess.remove_absolute(h.save_path)
	_check(not FileAccess.file_exists(h.save_path), "test cleans up its throwaway save file")

	print("test_high_score: %d passed, %d failed" % [_passed, _failed])
	quit(1 if _failed > 0 else 0)
