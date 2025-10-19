extends Node

# !!! ADD PATHS TO OBS SCENES
#preload obtsacles
var bevo = preload("res://scenes/Game/Obstacles/bevo.tscn")
var tiger
var mustang
var veo = preload("res://scenes/Game/Obstacles/veo.tscn")
var zach
var frog
var obstacle_types: = [bevo, veo] #array for normal obstacles
var active_obstacles: Array
#!!! CHANGE TO FIT REV HEIGHT !!!
var frog_heights: = [200, 390] #heights for frog to spawn
# !!! need to give value above screen
var zach_spawn_height: int

#game consts
# !!! CHANGE TO FIT OUR BACKGROUND !!!
const REV_START_POS: = Vector2i(280,744)
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

# rev animation state
const rev_idle = "IDLE"
const rev_ollie = "OLLIE"
const rev_kf = "KICKFLIP"
var rev_state = rev_idle

signal score_update(score)


#called when the node enters scene tree or first time
func _ready():
	screen_size = get_window().size
	ground_height = $Ground.get_node("Sprite2D").texture.get_height()
	#$GameOver.get_node("Button").pressed.connect(new_game) #when button pressed call new_game
	new_game()

func new_game():
	game_running = false #i forogt what this does
	get_tree().paused = false
	
	#reset vars
	score = 0
	speed_change = 0
	difficulty = 0
	
	#reset obstacles
	for obs in active_obstacles:
		obs.queue_free()
	active_obstacles.clear()
	
	#reset rev and camera
	$Rev.position = REV_START_POS
	$Rev.velocity = Vector2i(0, 0)
	rev_state = rev_idle
	_animate_rev(rev_state)
	$Skateboard.position = BOARD_START_POS
	$Skateboard.velocity = Vector2i(0, 0)
	$Camera2D.position = CAM_START_POS
	$Ground.position = Vector2i(0, 0)

	#$GameOver.hide()

func _animate_rev(state):
	$Rev/AnimatedSprite2D.animation = state


#called every frame; delta is elasped time since last frame
func _process(delta):
	if game_running:
		if Input.is_key_pressed(KEY_R):
			new_game()
		#speed up and adjust difficulty
		speed = START_SPEED + speed_change / SPEED_MODIFIER #gradually increases speed as score increases
		speed_change += speed
		
		if speed > MAX_SPEED:
			speed = MAX_SPEED
		adjust_difficulty()
		
		#generate obstacles
		generate_obs()
		
		#move dino and camera
		$Rev.position.x += speed
		$Skateboard.position.x += speed
		$Camera2D.position.x += speed
		
		# !!! UPDATE SCORE WHEN TRICK IS PERFORMED??? !!!
		#score = (score + speed) / SCORE_MODIFIER
		
		#show_score()
		score_update.emit(score)
		
		#update ground position
		if $Camera2D.position.x - $Ground.position.x > screen_size.x * 1.5:
			$Ground.position.x += screen_size.x
		
		#remove off screen obs
		for obs in active_obstacles:
			if obs.position.x < ($Camera2D.position.x - screen_size.x):
				remove_obs(obs)
		
	elif Input.is_anything_pressed():
		game_running = true
		$HUD.get_node("StartLabel").hide()


func generate_obs():
	#genrerate ground obstacle
	if active_obstacles.is_empty() or last_obs.position.x < score + randi_range(300,500): #instead of using timer, add obstacle once previous obstacle is psat a random point
		var obs
		#additional random chance to spawn a frog
		if difficulty >= MED_DIFFICULTY and randi()%2 == 0:
			obs = frog.instantiate()
			var frog_x: int = screen_size.x + speed_change + 100
			var frog_y: int = frog_heights[randi() % frog_heights.size()]
			add_obs(obs, frog_x, frog_y)
		elif difficulty == MAX_DIFFICULTY and (randi()%5) == 0:
			obs = zach.instantiate()
			var zach_x: int = screen_size.x + speed_change + 100
			var zach_y: int = zach_spawn_height
			add_obs(obs, zach_x, zach_y)
		else:
			obs = obstacle_types[randi() % obstacle_types.size()].instantiate()
			var obs_height = obs.get_node("Sprite2D").texture.get_height() #asking for height of obs
			var obs_scale = obs.get_node("Sprite2D").scale
			var obs_x: int = screen_size.x + speed_change + 100 #+speed_change bc game is const moving to the left; +100 for buffer
			var obs_y: int = screen_size.y - ground_height - (obs_height*obs_scale.y /2) + 5
			add_obs(obs, obs_x, obs_y)
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
	$HUD.get_node("ScoreLabel").text = "SCORE: " + str(score)

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
	get_tree().call_deferred("change_scene_to_file","res://scenes/States/end_scene.tscn")
