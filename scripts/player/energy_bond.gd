extends Line2D
class_name EnergyBond

## Presentation-only bond between PlayerPair's two entities (Milestone 17
## pivot). Reads entity positions and OrbitController's energy_level via
## update() and renders accordingly - never writes back into gameplay
## state. Nothing here has a reference to PlayerPair or OrbitController;
## it only knows the numbers it's handed each call.
##
## For this first playable slice: a 3-point Line2D (not a full sampled
## Bezier) - the midpoint bows perpendicular to the A-B segment by an
## amount proportional to energy_level, giving a simple "bond bows outward
## while inhaling, relaxes flat while exhaling" feel without curve
## sampling, shaders, or particles. Width and alpha also scale with
## energy_level so the bond visibly intensifies on inhale and calms on
## exhale.

@export var min_width: float = 3.0
@export var max_width: float = 10.0
@export var min_alpha: float = 0.35
@export var max_alpha: float = 1.0
## How far the midpoint bows perpendicular to the A-B line at full energy.
@export var curvature_amplitude: float = 20.0

func _init() -> void:
	default_color = Color(0.4, 0.85, 1.0, min_alpha)

## Pure: given the two entity positions (in this node's local space) and
## the current energy_level (0-1), returns the 3-point curve
## [a, bowed_midpoint, b]. Separated from update() so the geometry itself
## is testable without a live Line2D instance. Guards the degenerate
## coincident-entities case (zero-length segment) so it never normalizes a
## zero vector.
static func compute_points(entity_a: Vector2, entity_b: Vector2, energy_level: float, curvature_amplitude: float) -> PackedVector2Array:
	var midpoint := (entity_a + entity_b) / 2.0
	var segment := entity_b - entity_a
	var perpendicular := Vector2(-segment.y, segment.x).normalized() if segment.length() > 0.0 else Vector2.ZERO
	var bowed_midpoint := midpoint + perpendicular * curvature_amplitude * energy_level
	return PackedVector2Array([entity_a, bowed_midpoint, entity_b])

## Updates this bond's rendered geometry/width/alpha for the given frame's
## entity positions and energy_level. The only way anything drives this
## node - it never reads gameplay state back out.
func update(entity_a: Vector2, entity_b: Vector2, energy_level: float) -> void:
	points = compute_points(entity_a, entity_b, energy_level, curvature_amplitude)
	width = lerp(min_width, max_width, energy_level)
	var color := default_color
	color.a = lerp(min_alpha, max_alpha, energy_level)
	default_color = color
