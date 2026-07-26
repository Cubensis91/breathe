extends RefCounted
class_name ScrollManager

## Drives the endless-world illusion: forward scroll speed and an
## accumulating distance value. Pure arithmetic, no scene/Node dependency,
## so it's trivially unit-testable.
##
## Milestone 9: scroll_speed is no longer constant - it's recomputed each
## advance() from distance_traveled via a DifficultyCurve, so the game
## speeds up the longer a run lasts. distance_traveled also feeds
## Milestone 10 scoring.

const DifficultyCurveScript = preload("res://scripts/world/difficulty_curve.gd")

var difficulty := DifficultyCurveScript.new()
var scroll_speed: float = difficulty.base_speed
var distance_traveled: float = 0.0

func advance(delta: float) -> float:
	distance_traveled += scroll_speed * delta
	scroll_speed = difficulty.compute_scroll_speed(distance_traveled)
	return distance_traveled
