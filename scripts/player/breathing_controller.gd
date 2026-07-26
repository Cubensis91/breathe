extends Node
class_name BreathingController

## Breathing mechanic (Milestone 5): translates hold/release intent into
## vertical velocity.
##
## HOLD    -> inhale -> rise    (accelerate upward, clamp at max_rise_speed)
## RELEASE -> exhale -> descend (accelerate downward, clamp at max_fall_speed)
##
## Godot's Y axis increases downward, so "rise" is negative velocity and
## "descend" is positive velocity.
##
## Deliberately does not reference Player or any scene node - it only knows
## hold/release state and produces a velocity number. Wiring this into an
## actual Player in a live scene is later milestones' job (world/gameplay
## scene). This keeps the physics math testable without a scene tree.
##
## Milestone 11: _unhandled_input ignores touch/mouse events unless
## GameState.is_playing() (looked up the same lazy, tree-dependent way as
## scripts/world/world.gd's get_game_state() - see that file's comment for
## why this isn't the bare "GameState" identifier). Under headless tests
## (bare, un-added instances), this is always null, so existing tests that
## call set_holding()/compute_velocity_y() directly are unaffected.

## Acceleration applied while holding, in px/s^2.
var rise_acceleration: float = 900.0
## Acceleration applied while released, in px/s^2.
var fall_acceleration: float = 900.0
## Maximum upward speed (px/s), reached while holding.
var max_rise_speed: float = 260.0
## Maximum downward speed (px/s), reached while released.
var max_fall_speed: float = 260.0

var is_holding: bool = false

## Input-facing entry point. _unhandled_input below calls this for real
## touch/mouse events; tests call it directly to simulate hold/release
## without needing to synthesize InputEvents.
func set_holding(value: bool) -> void:
	is_holding = value

## Physics-facing pure function: given the current vertical velocity and a
## timestep, returns the new vertical velocity. Reads only is_holding and
## the tunable constants above - no Player/scene state.
func compute_velocity_y(current_velocity_y: float, delta: float) -> float:
	var target_speed := -max_rise_speed if is_holding else max_fall_speed
	var acceleration := rise_acceleration if is_holding else fall_acceleration
	return move_toward(current_velocity_y, target_speed, acceleration * delta)

func get_game_state():
	if not is_inside_tree():
		return null
	return get_node_or_null("/root/GameState")

func _unhandled_input(event: InputEvent) -> void:
	var game_state = get_game_state()
	if game_state and not game_state.is_playing():
		return
	if event is InputEventScreenTouch:
		set_holding(event.pressed)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		set_holding(event.pressed)
