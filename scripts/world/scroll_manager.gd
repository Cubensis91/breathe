extends RefCounted
class_name ScrollManager

## Drives the endless-world illusion: a constant forward scroll speed and an
## accumulating distance value. Pure arithmetic, no scene/Node dependency,
## so it's trivially unit-testable.
##
## distance_traveled feeds later milestones (9 - difficulty scaling,
## 10 - scoring) - not used for anything but its own accumulation yet.

var scroll_speed: float = 200.0
var distance_traveled: float = 0.0

func advance(delta: float) -> float:
	distance_traveled += scroll_speed * delta
	return distance_traveled
