extends Node2D
class_name Obstacle

## Static obstacle (Milestone 8): a fixed position + a collision radius,
## nothing else. "Static" just means there's no movement behavior - it
## sits wherever it's placed in world-space (see obstacle.tscn).
##
## radius matches what scripts/systems/collision_system.gd's
## check_obstacles() expects: anything with a "position" and a "radius".
## Deliberately not an Area2D/CollisionShape2D - Milestone 7 decided
## collision is pure geometry, not Godot physics-engine overlap detection,
## so no physics body is needed here.

@export var radius: float = 24.0
