extends ParallaxBackground

var screen_size

var green_anom_1 = "res://scenes/green_anom_1.tscn"
var green_anom_2 = "res://scenes/green_anom_2.tscn"
var green1 = "res://scenes/green_1.tscn"
var green2 = "res://scenes/green_2.tscn"
var green3 = "res://scenes/green_3.tscn"
var green4 = "res://scenes/green_4.tscn"
var green5 = "res://scenes/green_5.tscn"
var green6 = "res://scenes/green_6.tscn"
var green7 = "res://scenes/green_7.tscn"
var green8 = "res://scenes/green_8.tscn"

var fbush1 = "res://assets/Background/Foreground/fore_bush1.png"
var fbush2 = "res://assets/Background/Foreground/fore_bush2.png"
var ftree1 = "res://assets/Background/Foreground/fore_tree1.png"
var ftree1_anom = "res://assets/Background/Foreground/fore_tree1_anomaly.png"
var ftree2 = "res://assets/Background/Foreground/fore_tree2.png"
var ftree2_anom = "res://assets/Background/Foreground/fore_tree2_anomaly.png"

var green_types: = [green1, green2, green3, green4, green5, green6, green7, green8] #array for normal obstacles
var active_green: Array
var last_green


func _ready():
	screen_size = get_window().size

# !!! IF THIS DOESN'T WORK PUT SPRITE ON PARALLAX LAYER ITSELF
func _process(delta):
	#remove off screen obs
	for g in active_green:
		if g.position.x < ($Game.get_node("Camera2D").position.x - screen_size.x):
			remove_green(g)

func generate_obs():
	#genrerate ground obstacle
	if active_green.is_empty() or last_green.position.x < $Game.get_node("Camera2D").position.x + randi_range(300,500): #instead of using timer, add obstacle once previous obstacle is psat a random point
		var green	
		#anom chances of appearing
		if randi()%20 == 0:
			green = green_anom_1.instantiate()
		elif randi()%50 == 0:
			green = green_anom_2.instantiate()
		else:
			green = green_types[randi() % green_types.size()].instantiate()
			
		var green_height = green.get_node("Sprite2D").texture.get_height() #asking for height of obs
		var green_scale = green.get_node("Sprite2D").scale
		#NEED TO GET THESE VARS FROM GAME NODE
		var green_x: int = screen_size.x + get_parent().speed_change + 100 #+speed_change bc game is const moving to the left; +100 for buffer
		var green_y: int = screen_size.y - get_parent().ground_height - (green_height*green_scale.y /2) + 5
		add_green(green, green_x, green_y)
		last_green = green

func add_green(green, x, y):
	green.position = Vector2i(x, y)
	add_child(green)
	active_green.append(green)
	
func remove_green(green):
	green.queue_free() #removes obstacle
	active_green.erase(green) #remove from array
