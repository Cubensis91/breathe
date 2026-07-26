extends RefCounted
class_name DifficultyCurve

## Pure difficulty curve (Milestone 9): forward scroll speed increases
## linearly with distance traveled, capped at max_speed so the game
## doesn't become unplayably fast. No scene/Node dependency, so it's
## trivially unit-testable.

var base_speed: float = 200.0
var max_speed: float = 500.0
## How fast difficulty ramps up: additional px/s of scroll speed per px of
## distance traveled.
var ramp_rate: float = 0.05

func compute_scroll_speed(distance_traveled: float) -> float:
	return min(base_speed + distance_traveled * ramp_rate, max_speed)
