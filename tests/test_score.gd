extends SceneTree

## Headless test for scripts/systems/score.gd.
## Run via: godot4 --headless -s res://tests/test_score.gd

const ScoreScript = preload("res://scripts/systems/score.gd")

var _passed := 0
var _failed := 0

func _check(condition: bool, description: String) -> void:
	if condition:
		_passed += 1
	else:
		_failed += 1
		print("FAIL: %s" % description)

func _initialize() -> void:
	_check(ScoreScript.compute(0.0) == 0, "zero distance is zero score")
	_check(ScoreScript.compute(100.0) == 10, "score scales down distance by DISTANCE_PER_POINT")
	_check(ScoreScript.compute(95.0) == 9, "score floors rather than rounds up")
	_check(ScoreScript.compute(1000.0) > ScoreScript.compute(500.0), "score increases monotonically with distance")

	print("test_score: %d passed, %d failed" % [_passed, _failed])
	quit(1 if _failed > 0 else 0)
