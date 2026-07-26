extends Node

## Central game state machine. Autoloaded as "GameState" (see project.godot).
##
## This is the one piece of state every other system (player, world, UI,
## audio) reads or reacts to, so it lives at the core of the architecture
## rather than inside any particular gameplay system.

enum State { MENU, PLAYING, DEAD }

## previous, current
signal state_changed(previous: State, current: State)

var current_state: State = State.MENU

const _ALLOWED_TRANSITIONS := {
	State.MENU: [State.PLAYING],
	State.PLAYING: [State.DEAD],
	State.DEAD: [State.PLAYING, State.MENU],
}

## Returns true if the transition happened, false if it was rejected
## (illegal transition) or was a no-op (already in that state).
func transition_to(new_state: State) -> bool:
	if new_state == current_state:
		return false
	if not new_state in _ALLOWED_TRANSITIONS.get(current_state, []):
		push_warning("GameState: rejected illegal transition %s -> %s" % [
			State.keys()[current_state], State.keys()[new_state]
		])
		return false
	var previous := current_state
	current_state = new_state
	state_changed.emit(previous, current_state)
	return true

func is_menu() -> bool:
	return current_state == State.MENU

func is_playing() -> bool:
	return current_state == State.PLAYING

func is_dead() -> bool:
	return current_state == State.DEAD
