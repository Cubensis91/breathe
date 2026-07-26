extends Area2D
class_name Player

## class_name gives this a global type name once a project scan has run
## (e.g. on PC in the Editor), but nothing here relies on that - the
## explicit preload below works identically with or without a global class
## cache, which matters since this project is developed headlessly.
const BreathingControllerScript = preload("res://scripts/player/breathing_controller.gd")

## Player controller. Holds position/velocity state and integrates position
## from velocity each physics step.
##
## Area2D (not CharacterBody2D) because obstacle collision in this game is
## overlap-triggered death, not physical collision response.
##
## Vertical velocity is driven by an optional child BreathingController
## (Milestone 5/6) if one exists as a direct child named "BreathingController";
## otherwise velocity.y is left alone (Milestone 4 behavior - useful for
## tests that exercise integrate_physics() in isolation). Horizontal
## velocity (forward world scroll) is set externally by whatever owns this
## Player (see scripts/world/world.gd) - Player itself has no opinion on it.
##
## Looked up lazily via get_node_or_null() rather than cached with @onready,
## so this works identically whether the node is freshly instantiated,
## added to a live scene tree, or neither (as in headless unit tests).

var velocity: Vector2 = Vector2.ZERO

func get_breathing() -> BreathingControllerScript:
	return get_node_or_null("BreathingController") as BreathingControllerScript

func integrate_physics(delta: float) -> void:
	var breathing := get_breathing()
	if breathing:
		velocity.y = breathing.compute_velocity_y(velocity.y, delta)
	position += velocity * delta

func _physics_process(delta: float) -> void:
	integrate_physics(delta)
