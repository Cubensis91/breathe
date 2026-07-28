extends RefCounted
class_name OrbitController

## Orbit/bond mechanic (Concept v2 - Vertical Ascent pivot): drives the two
## entities' shared rotation and the bond's energy state from a single
## breathing signal, using the same move_toward-ramp shape already
## established by scripts/player/breathing_controller.gd's
## compute_velocity_y(). Pure RefCounted, no scene/Node dependency, so it's
## fully unit-testable without a live scene tree - same discipline as
## scripts/world/scroll_manager.gd and scripts/world/difficulty_curve.gd.
##
## Deliberately does not own center_position or any world-space concept -
## that's the future PlayerPair/World's job (composing this orbit's state
## with the pair's ascending position). This class only knows the pair's
## rotation and energy, not where the pair is in the world.
##
## is_holding is intentionally a parameter here, not stored state -
## BreathingController remains the single source of truth for hold/release
## input; this class just reacts to it each step, avoiding two owners of
## the same boolean.

const ENTITY_A_OFFSET: float = 0.0
const ENTITY_B_OFFSET: float = PI

## Current rotation of the pair around the shared center, in radians.
var angle: float = 0.0
## Current angular speed (rad/s). Sign indicates direction of rotation.
var angular_velocity: float = 0.0
## Distance from the shared center to each entity.
var radius: float = 60.0

## Bond energy: 0.0 (fully calm/exhaled) to 1.0 (fully intense/inhaled).
## A derived gameplay value from breathing state (not rendering state) -
## the future EnergyBond presentation node reads this to drive brightness/
## width/alpha, but never writes it.
var energy_level: float = 0.0

## Angular acceleration applied while ramping toward the current target
## angular speed, in rad/s^2.
var angular_acceleration: float = PI
## Magnitude of angular speed reached while holding/releasing (direction
## flips with is_holding - see compute_angular_velocity).
var max_angular_speed: float = PI / 2.0

## Rate energy_level rises toward 1.0 while holding, and falls toward 0.0
## while released, in full-scale units per second.
var energy_rise_rate: float = 2.0
var energy_fall_rate: float = 1.5

## Pure: given the current angular velocity and hold state, returns the new
## angular velocity after ramping toward the target for this delta. Same
## move_toward-ramp shape as BreathingController.compute_velocity_y().
func compute_angular_velocity(current_angular_velocity: float, is_holding: bool, delta: float) -> float:
	var target_speed := max_angular_speed if is_holding else -max_angular_speed
	return move_toward(current_angular_velocity, target_speed, angular_acceleration * delta)

## Pure: given the current energy level and hold state, returns the new
## energy level after ramping toward 1.0 (holding) or 0.0 (released),
## clamped to [0, 1].
func compute_energy_level(current_energy_level: float, is_holding: bool, delta: float) -> float:
	var target := 1.0 if is_holding else 0.0
	var rate := energy_rise_rate if is_holding else energy_fall_rate
	return clamp(move_toward(current_energy_level, target, rate * delta), 0.0, 1.0)

## Advances angle, angular_velocity, and energy_level by one timestep, given
## the current hold state. Public (not tied to _physics_process) so tests
## can call it directly, matching ScrollManager.advance()'s convention.
func advance(delta: float, is_holding: bool) -> void:
	angular_velocity = compute_angular_velocity(angular_velocity, is_holding, delta)
	angle += angular_velocity * delta
	energy_level = compute_energy_level(energy_level, is_holding, delta)

## Pure: the offset from the shared center to an entity at the given angular
## offset (0 for Entity A, PI for Entity B), at the current angle/radius.
## Callers (future PlayerPair) add this to their own center_position - this
## class has no opinion on where the center is in world-space.
func get_entity_offset(angle_offset: float) -> Vector2:
	return Vector2(cos(angle + angle_offset), sin(angle + angle_offset)) * radius

func get_entity_a_offset() -> Vector2:
	return get_entity_offset(ENTITY_A_OFFSET)

func get_entity_b_offset() -> Vector2:
	return get_entity_offset(ENTITY_B_OFFSET)
