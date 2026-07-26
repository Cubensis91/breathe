extends "res://scripts/world/obstacle.gd"
class_name MovingObstacle

## Moving obstacle (Milestone 8): oscillates vertically around origin_y.
##
## Extends obstacle.gd via file-path `extends` (not the global class name)
## because class_name only becomes globally resolvable after a project
## scan, which this CLI-only workflow never triggers - see Milestone 6's
## docs/current_status.md note. File-path extends works regardless.
##
## origin_y is set explicitly (matching the node's initial position.y in
## the scene file) rather than captured via _ready(), so this doesn't
## depend on tree-entry timing - testable by just calling advance() with
## an arbitrary elapsed time.

@export var origin_y: float = 0.0
@export var amplitude: float = 100.0
@export var period: float = 2.0

var elapsed: float = 0.0

## Pure function: vertical offset from origin_y at a given elapsed time.
func compute_offset_y(elapsed_time: float) -> float:
	return amplitude * sin(TAU * elapsed_time / period)

func advance(delta: float) -> void:
	elapsed += delta
	position.y = origin_y + compute_offset_y(elapsed)

func _physics_process(delta: float) -> void:
	advance(delta)
