extends Node


var high_score = 0
const FILE_PATH = "user:://game_data.save"

func set_score(score):
	if score>high_score:
		high_score = score
		save_game_data()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_game_data()


func save_game_data():
	var file = FileAccess.open(FILE_PATH, FileAccess.WRITE)
	if file:
		var data = {"high_score":high_score}
		file.store_var(data)
		file.close()


func load_game_data():
	if FileAccess.file_exists(FILE_PATH):
		var file = FileAccess.open(FILE_PATH,FileAccess.READ)
		if file:
			var data = file.get_var()
			if data.has("high_score"):
				high_score = data.high_score
			file.close()
