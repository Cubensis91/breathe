extends RefCounted
class_name HighScorePersistence

## Local high-score save/load (Milestone 10). File I/O is Godot-specific
## (FileAccess), kept behind small load/save methods so the actual "is
## this a new record" rule (record_score) stays easy to reason about.
##
## save_path is overridable (tests point it at a throwaway user:// file
## instead of the real save, and clean it up afterward) rather than
## hardcoded, so this doesn't depend on mocking FileAccess itself.

var save_path: String = "user://high_score.save"

func load_high_score() -> int:
	if not FileAccess.file_exists(save_path):
		return 0
	var f := FileAccess.open(save_path, FileAccess.READ)
	if f == null:
		return 0
	var value := f.get_32()
	f.close()
	return value

func save_high_score(score: int) -> void:
	var f := FileAccess.open(save_path, FileAccess.WRITE)
	if f == null:
		return
	f.store_32(score)
	f.close()

## Compares score against the current saved high score. If it's a new
## record (strictly greater, not just equal), saves it and returns true;
## otherwise leaves the save untouched and returns false.
func record_score(score: int) -> bool:
	var current := load_high_score()
	if score > current:
		save_high_score(score)
		return true
	return false
