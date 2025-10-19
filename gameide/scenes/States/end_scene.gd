extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Control/VBoxContainer2/VBoxContainer/HBoxContainer/ScoreLabel.text = Global.live_score
	$Control/VBoxContainer2/VBoxContainer/HBoxContainer2/HighScoreLabel.text = Global.high_score


func _on_replay_button_pressed() -> void:
	# replay!
	print("replay (tbd)")
	pass # Replace with function body.
