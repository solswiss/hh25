extends Node

# !!! ADD PATHS TO OBS SCENES
#preload obtsacles
var bevo = preload("res://scenes/Game/Obstacles/bevo.tscn")
var tiger
var mustang
var veo = preload("res://scenes/Game/Obstacles/veo.tscn")
var zach
var frog = preload("res://scenes/Game/Obstacles/tcu_frog.tscn")
var obstacle_types: = [bevo, frog, veo] #array for normal obstacles
var active_obstacles: Array
#!!! CHANGE TO FIT REV HEIGHT !!!
var frog_heights: = [200, 390] #heights for frog to spawn
# !!! need to give value above screen
var zach_spawn_height: int

#game consts
# !!! CHANGE TO FIT OUR BACKGROUND !!!
const REV_START_POS: = Vector2i(280,800)
const BOARD_START_POS: = Vector2i(280,792)
const CAM_START_POS: = Vector2i(960, 540)
const START_SPEED: float = 10.0
const MAX_SPEED: int = 25
const SPEED_MODIFIER: int = 5000
const SCORE_MODIFIER: int = 10
const MED_DIFFICULTY: int = 2 #when flying obstacles start appearing
const MAX_DIFFICULTY: int = 5

#game vars
var screen_size: Vector2i
var ground_height: int
var game_running: bool
var speed: float
var speed_change: int
var score: int
var high_score: int
# !!! WE SHOULD HAVE DIFFICULTY LEVEL TO MAKE COMBOS HARDER AS THE GAME RUNS !!!
var difficulty
var last_obs


# obstacle/animation enum
enum Obstacle {
	VEO,
	ZACHRY,
	BEVO,
	TCU,
	SMU,
	LSU
}

signal score_update(score)
signal new_obstacle(obs)

#called when the node enters scene tree or first time
func _ready():
	screen_size = get_window().size
	ground_height = $Ground.get_node("Sprite2D").texture.get_height()
	#$GameOver.get_node("Button").pressed.connect(new_game) #when button pressed call new_game
	$Rev.connect("move",animate_board)
	new_game()
	$HUD/StartLabel.hide()

func animate_board(move:String):
	$Skateboard.get_node("AnimatedSprite2D").play(move)
	score += 1000
	show_score()

func new_game():
	game_running = false #i forogt what this does
	get_tree().paused = false
	
	#reset vars
	score = 0
	speed_change = 0
	difficulty = 0
	'''
	#reset obstacles
	for obs in active_obstacles:
		obs.queue_free()
	active_obstacles.clear()
	'''
	#reset rev and camera
	$Rev.position = REV_START_POS
	$Rev.velocity = Vector2i(0, 0)
	$Skateboard.position = BOARD_START_POS
	$Skateboard.velocity = Vector2i(0, 0)
	$Camera2D.position = CAM_START_POS
	$Ground.position = Vector2i(0, 0)

	#$GameOver.hide()

#called every frame; delta is elasped time since last frame
func _process(delta):
	print($Rev.position.y)
	if game_running:
		if Input.is_key_pressed(KEY_R):
			new_game()
		#speed up and adjust difficulty
		speed = START_SPEED + speed_change / SPEED_MODIFIER #gradually increases speed as score increases
		speed_change += speed
		#print(speed)
		if speed > MAX_SPEED:
			speed = MAX_SPEED
		adjust_difficulty()
		
		# generate obstacles
		#generate_obs()
		
		#move dino and camera
		$Skateboard.position.x += speed
		$Rev.position.x = $Skateboard.position.x
		$Camera2D.position.x += speed
		
		# !!! UPDATE SCORE WHEN TRICK IS PERFORMED??? !!!
		#score = (score + speed) / SCORE_MODIFIER
		
		#show_score()
		score_update.emit(score)
		
		#update ground position
		if $Camera2D.position.x - $Ground.position.x > screen_size.x * 1.5:
			$Ground.position.x += screen_size.x
	elif Input.is_action_pressed("ui_accept"):
		game_running = true
'''
		#remove off screen obs
		for obs in active_obstacles:
			if obs.position.x < ($Camera2D.position.x - screen_size.x):
				remove_obs(obs)
	'''	
		
func generate_obs():
	#genrerate ground obstacle
	if active_obstacles.is_empty() or last_obs.position.x < score + randi_range(300,500): #instead of using timer, add obstacle once previous obstacle is psat a random point
		var obs = obstacle_types.pick_random()
		add_obs(obs, 1000, 750)
		new_obstacle.emit(obs)
		last_obs = obs
	
func add_obs(obs, x, y):
	obs.position = Vector2i(x, y)
	obs.body_entered.connect(hit_obs) #hit_obs will trigger whenever body_entered happens
	obs.add_to_group("Obstacles")
	add_child(obs)
	active_obstacles.append(obs)
	
func remove_obs(obs):
	obs.queue_free() #removes obstacle
	active_obstacles.erase(obs) #remove from array

func hit_obs(body):
	if body.name == "Rev":
		game_over()

func show_score():
	$HUD/VBoxContainer/ScoreLabel.text = "SCORE: " + str(score)

func check_high_score():
	if score > high_score:
		high_score = score
		$HUD.get_node("HighScoreLabel").text = "HIGH SCORE: " + str(high_score)
		Global.set_high_score(score)

func adjust_difficulty():
	difficulty = speed_change/SPEED_MODIFIER
	if difficulty > MAX_DIFFICULTY:
		difficulty = MAX_DIFFICULTY

func game_over():
	check_high_score()
	#GameOver scene > Process tab > Mode: When Paused so GameOver scene only works when game is paused
	get_tree().paused = true #pauses whole game
	game_running = false
	Global.live_score = score
	get_tree().change_scene_to_file("res://scenes/end_scene.tscn")
