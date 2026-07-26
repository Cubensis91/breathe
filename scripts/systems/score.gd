extends RefCounted
class_name Score

## Converts raw distance traveled (px, from ScrollManager) into a display
## score (Milestone 10). A single pure function, so the scale factor has
## one source of truth instead of getting scattered across World/UI code.

const DISTANCE_PER_POINT: float = 10.0

static func compute(distance_traveled: float) -> int:
	return int(distance_traveled / DISTANCE_PER_POINT)
