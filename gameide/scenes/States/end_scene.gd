extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Control/VBoxContainer2/VBoxContainer/HBoxContainer/ScoreLabel.text = str(Global.live_score)
	$Control/VBoxContainer2/VBoxContainer/HBoxContainer2/HighScoreLabel.text = str(Global.high_score)
	$Control/VBoxContainer2/ReplayButton.pressed.connect(replay)
	print("ok")


func replay():
	print("replay")
	get_tree().change_scene_to_file("res://scenes/Game/game.tscn")
