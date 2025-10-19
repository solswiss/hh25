extends Node

#preload obtsacles
#var stump_scene = preload("res://scenes/stump.tscn")
#var rock_scene = preload("res://scenes/rock.tscn")
#var barrel_scene = preload("res://scenes/barrel.tscn")
#var bird_scene = preload("res://scenes/bird.tscn")
#var obstacle_types: = [stump_scene, rock_scene, barrel_scene]
var obstacles: Array
#var bird_heights: = [200, 390] #heights for frog to spawn

#game consts
const REV_START_POS: = Vector2i(150,485)
const CAM_START_POS: = Vector2i(576, 324)
const START_SPEED: float = 10.0
const MAX_SPEED: int = 25
const SPEED_MODIFIER: int = 5000
const SCORE_MODIFIER: int = 10
const MAX_DIFFICULTY: int = 2

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

#called when the node enters scene tree or first time
func _ready():
	screen_size = get_window().size
	ground_height = $Ground.get_node("Sprite2D").texture.get_height()
	# !!! change to end screen !!!
	#$GameOver.get_node("Button").pressed.connect(new_game) #when button pressed call new_game
	new_game()

func new_game():
	game_running = false
	get_tree().paused = false
	
	#reset vars
	score = 0
	speed_change = 0
	show_score()
	difficulty = 0
	
	#reset obstacles
	for obs in obstacles:
		obs.queue_free()
	obstacles.clear()
	
	#reset rev and camera
	$Rev.position = REV_START_POS
	$Rev.velocity = Vector2i(0, 0)
	$Camera2D.position = CAM_START_POS
	$Ground.position = Vector2i(0, 0)
	
	$HUD.get_node("StartLabel").show()
	$HUD.get_node("HighScoreLabel").text = Global.high_score
	$GameOver.hide()

#called every frame; delta is elasped time since last frame
func _process(delta):
	if game_running:
		#speed up and adjust difficulty
		speed = START_SPEED + speed_change / SPEED_MODIFIER #gradually increases speed as score increases
		speed_change += speed
		#print(speed)
		if speed > MAX_SPEED:
			speed = MAX_SPEED
		adjust_difficulty()
		
		#generate obstacles
		generate_obs()
		
		#move dino and camera
		$Rev.position.x += speed
		$Camera2D.position.x += speed
		
		# !!! UPDATE SCORE WHEN TRICK IS PERFORMED??? !!!
		#score = (score + speed) / SCORE_MODIFIER
		show_score()
		
		#update ground position
		if $Camera2D.position.x - $Ground.position.x > screen_size.x * 1.5:
			$Ground.position.x += screen_size.x
			
		#remove off screen obs
		for obs in obstacles:
			if obs.position.x < ($Camera2D.position.x - screen_size.x):
				remove_obs(obs)
		
	else:
		#if Input.is_action_pressed("ui_accept"):
			game_running = true
			$HUD.get_node("StartLabel").hide()

# !!! CHANGE TO CREATE GROUPS OF OBSTACLES INSTEAD !!!
func generate_obs():
	#genrerate ground obstacle
	if obstacles.is_empty() or last_obs.position.x < score + randi_range(300,500): #instead of using timer, add obstacle once previous obstacle is psat a random point
		var obs_type = obstacle_types[randi() % obstacle_types.size()]
		var obs
		var max_obs = difficulty + 1 #lets obstacles generate as clusters as difficulty increases
		for i in range(randi() % max_obs + 1):
			obs = obs_type.instantiate()
			var obs_height = obs.get_node("Sprite2D").texture.get_height() #asking for height of obs
			var obs_scale = obs.get_node("Sprite2D").scale
			var obs_x: int = screen_size.x + score + 100 + (i*100) #+score bc game is const moving to the left; +100 for buffer; i*100 so clusters obs will appear one after another
			var obs_y: int = screen_size.y - ground_height - (obs_height*obs_scale.y /2) + 5
			last_obs = obs
			add_obs(obs, obs_x, obs_y)
		#additional random cahnce to spawn a bird
		if difficulty == MAX_DIFFICULTY:
			if (randi()%2 ) == 0: #50/50 chance
				obs = bird_scene.instantiate()
				var obs_x: int = screen_size.x + score + 100
				var obs_y: int = bird_heights[randi() % bird_heights.size()]
				add_obs(obs, obs_x, obs_y)
	
func add_obs(obs, x, y):
	obs.position = Vector2i(x, y)
	obs.body_entered.connect(hit_obs) #hit_obs will trigger whenever body_entered happens
	add_child(obs)
	obstacles.append(obs)
	
func remove_obs(obs):
	obs.queue_free() #removes obstacle
	obstacles.erase(obs) #remove from array

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
	difficulty = score/SPEED_MODIFIER
	if difficulty > MAX_DIFFICULTY:
		difficulty = MAX_DIFFICULTY

func game_over():
	check_high_score()
	#GameOver scene > Process tab > Mode: When Paused so GameOver scene only works when game is paused
	get_tree().paused = true #pauses whole game
	game_running = false
	$GameOver.show()
