extends Node
class_name AudioController

## Audio routing (Milestone 12): decides *whether* a sound should play
## (settings on/off, stream assigned or not) - not what the sound sounds
## like. No real audio assets exist yet (see docs/current_status.md), so
## every AudioStreamPlayer child in audio_controller.tscn has no stream
## assigned. Calling play_*() is always safe: it silently does nothing
## without a stream, exactly like Player.get_breathing() silently does
## nothing without a BreathingController child. Adding real audio later
## is purely an asset change (assign a stream in the scene) - no code here
## needs to change.

const AudioSettingsScript = preload("res://scripts/audio/audio_settings.gd")

var settings := AudioSettingsScript.new()

func _play(node_name: String) -> void:
	if not settings.is_enabled():
		return
	var player := get_node_or_null(node_name) as AudioStreamPlayer
	if player and player.stream:
		player.play()

func play_inhale() -> void:
	_play("Inhale")

func play_collision() -> void:
	_play("Collision")

func play_game_over() -> void:
	_play("GameOver")

## Starts the music loop if it isn't already playing. Safe to call
## repeatedly - a no-op once music is already underway, or if disabled/no
## stream assigned.
func start_music() -> void:
	if not settings.is_enabled():
		return
	var music := get_node_or_null("Music") as AudioStreamPlayer
	if music and music.stream and not music.playing:
		music.play()

func stop_music() -> void:
	var music := get_node_or_null("Music") as AudioStreamPlayer
	if music:
		music.stop()
