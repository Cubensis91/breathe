extends Area2D
class_name Player

## Placeholder player controller (Milestone 4).
##
## Holds position/velocity state and integrates position from velocity each
## physics step. What actually *drives* velocity - breathing input, gravity,
## clamping - is deliberately out of scope here (Milestone 5). This class
## only knows how to move given a velocity, so it's testable in isolation
## before any input handling exists.
##
## Area2D (not CharacterBody2D) because obstacle collision in this game is
## overlap-triggered death, not physical collision response.

var velocity: Vector2 = Vector2.ZERO

func integrate_physics(delta: float) -> void:
	position += velocity * delta

func _physics_process(delta: float) -> void:
	integrate_physics(delta)
