extends RefCounted
class_name AudioSettings

## Local audio on/off setting (Milestone 12), following the same pattern
## as scripts/systems/high_score.gd: FileAccess-backed, overridable
## save_path so tests use a throwaway file instead of a real save.
##
## Reads from disk each call rather than caching in memory - there's no
## meaningful performance pressure here, and it keeps this trivially
## simple/stateless, consistent with HighScorePersistence.

var save_path: String = "user://audio_settings.save"

func is_enabled() -> bool:
	if not FileAccess.file_exists(save_path):
		return true
	var f := FileAccess.open(save_path, FileAccess.READ)
	if f == null:
		return true
	var value := f.get_8() != 0
	f.close()
	return value

func set_enabled(value: bool) -> void:
	var f := FileAccess.open(save_path, FileAccess.WRITE)
	if f == null:
		return
	f.store_8(1 if value else 0)
	f.close()

## Flips the setting and returns the new value.
func toggle() -> bool:
	var new_value := not is_enabled()
	set_enabled(new_value)
	return new_value
