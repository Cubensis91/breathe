extends RefCounted
class_name ObstacleSpawner

## Procedural spawn-timing rule (Milestone 9): decides WHEN a spawn should
## happen, independent of Godot nodes/scenes - so the rule itself is fully
## testable without instancing anything. Deciding WHAT to spawn and
## actually creating a node is scripts/world/world.gd's job (Godot-specific
## side effects belong in the scene script, not here).

var spawn_interval: float = 400.0    # px of distance between spawns (base)
var min_interval: float = 200.0      # tightest spacing at max difficulty
var interval_ramp_rate: float = 0.02 # how fast spacing tightens with distance

var next_spawn_distance: float = 400.0

## Pure: how far apart spawns should be at this distance_traveled - shrinks
## with distance (more obstacles, closer together) but never below min_interval.
func compute_interval(distance_traveled: float) -> float:
	return max(spawn_interval - distance_traveled * interval_ramp_rate, min_interval)

## Call once per step with the current distance_traveled. Returns true
## exactly when a spawn should happen, and advances next_spawn_distance so
## it won't fire again until the next threshold.
func should_spawn(distance_traveled: float) -> bool:
	if distance_traveled >= next_spawn_distance:
		next_spawn_distance += compute_interval(distance_traveled)
		return true
	return false
