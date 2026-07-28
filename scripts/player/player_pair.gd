extends Node2D
class_name PlayerPair

## PlayerPair (Milestone 17 pivot): composes two entities orbiting a shared
## center, driven by a single OrbitController + the same BreathingController
## reused from the original Player (see scripts/player/breathing_controller.gd
## and scripts/player/player.gd).
##
## BreathingController itself is unchanged and still reused as-is (same
## hold/release -> compute_velocity_y ramp) - it no longer drives a bare
## Player's velocity.y directly, though. PlayerPair is now the one place
## that reads breathing intent and applies it to both the pair's vertical
## ascent/descent AND OrbitController's angle/energy, so OrbitController
## (not BreathingController, not a bare Player) is the authoritative source
## of the pair's orbit state.
##
## orbit is owned directly (a plain instance field, not a child node
## lookup) so it's always present even on a bare, childless PlayerPair -
## matching OrbitController's own "no scene/Node dependency" design.
##
## EntityA/EntityB/EnergyBond are looked up lazily via get_node_or_null(),
## the same discipline scripts/player/player.gd already uses - this works
## identically whether PlayerPair is bare, scene-instantiated, or added to
## a live tree. EnergyBond is only ever written to via its own update() -
## PlayerPair never reads anything back from it.

const BreathingControllerScript = preload("res://scripts/player/breathing_controller.gd")
const OrbitControllerScript = preload("res://scripts/player/orbit_controller.gd")
const EnergyBondScript = preload("res://scripts/player/energy_bond.gd")

var orbit := OrbitControllerScript.new()
var velocity: Vector2 = Vector2.ZERO

func get_breathing() -> BreathingControllerScript:
	return get_node_or_null("BreathingController") as BreathingControllerScript

func get_entity_a() -> Node2D:
	return get_node_or_null("EntityA") as Node2D

func get_entity_b() -> Node2D:
	return get_node_or_null("EntityB") as Node2D

func get_energy_bond() -> EnergyBondScript:
	return get_node_or_null("EnergyBond") as EnergyBondScript

## Advances orbit/energy state and vertical ascent/descent by one timestep,
## then updates the child entities' positions and the energy bond's
## rendering state to match. Public (not just _physics_process) so tests
## can call it directly, matching Player.integrate_physics()'s convention.
func integrate_physics(delta: float) -> void:
	var breathing := get_breathing()
	var is_holding := breathing.is_holding if breathing else false

	orbit.advance(delta, is_holding)

	if breathing:
		velocity.y = breathing.compute_velocity_y(velocity.y, delta)
	position += velocity * delta

	var entity_a := get_entity_a()
	var entity_b := get_entity_b()
	if entity_a:
		entity_a.position = orbit.get_entity_a_offset()
	if entity_b:
		entity_b.position = orbit.get_entity_b_offset()

	var bond := get_energy_bond()
	if bond and entity_a and entity_b:
		bond.update(entity_a.position, entity_b.position, orbit.energy_level)

func _physics_process(delta: float) -> void:
	integrate_physics(delta)
