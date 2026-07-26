extends RefCounted
class_name CollisionSystem

## Collision rule (Milestone 7): decoupled from Godot's physics engine and
## from any specific obstacle representation, so it's fully testable
## without a live scene tree or physics frames.
##
## There are no real obstacle nodes yet (Milestone 8). Obstacles are
## represented here as plain Dictionaries with "position": Vector2 and
## "radius": float - whatever Milestone 8's actual obstacle scenes turn out
## to be, wiring them into check_obstacles() just means reading those two
## values off them at call time. Wiring this into an actual Player/World
## physics loop is Milestone 8's job, once there's something real to check
## against.

## Pure geometry: do two circles overlap (touching counts as overlapping).
static func circles_overlap(pos_a: Vector2, radius_a: float, pos_b: Vector2, radius_b: float) -> bool:
	return pos_a.distance_to(pos_b) <= radius_a + radius_b

## Checks the player against a list of obstacles and triggers death via the
## given game_state if any overlap while playing. Returns true if death was
## triggered.
##
## game_state is passed in explicitly rather than reaching for the
## GameState autoload directly, so this stays testable with an isolated
## GameState instance (see tests/test_game_state.gd's approach) instead of
## depending on project-wide autoload state.
static func check_obstacles(player_position: Vector2, player_radius: float, obstacles: Array, game_state) -> bool:
	if not game_state.is_playing():
		return false
	for obstacle in obstacles:
		if circles_overlap(player_position, player_radius, obstacle.position, obstacle.radius):
			game_state.transition_to(game_state.State.DEAD)
			return true
	return false
