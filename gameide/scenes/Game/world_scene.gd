extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$HUD.get_node("VBoxContainer/HighScoreLabel").hide()
	$HUD.get_node("VBoxContainer/ScoreLabel").hide()


func update_score_label():
	$HUD.get_node("VBoxContainer/ScoreLabel").text = str(Global.live_score)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_anything_pressed():
		$HUD.get_node("StartLabel").hide()
		$HUD.get_node("VBoxContainer/HighScoreLabel").show()
		$HUD.get_node("HighScoreLabel").text = str(Global.high_score)
		$HUD.get_node("VBoxContainer/ScoreLabel").show()
		$Game.game_running = true
		$Game.connect("score_update",update_score_label)
