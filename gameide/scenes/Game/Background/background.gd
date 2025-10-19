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

var fbush1 = "res://scenes/Game/Background/ObjectScenes/fore_bush_1.tscn"
var fbush2 = "res://scenes/Game/Background/ObjectScenes/fore_bush_2.tscn"
var ftree1 = "res://scenes/Game/Background/ObjectScenes/fore_tree_1.tscn"
var fore_anom_1 = "res://scenes/Game/Background/ObjectScenes/fore_tree_anomaly_1.tscn"
var ftree2 = "res://scenes/Game/Background/ObjectScenes/fore_tree_2.tscn"
var fore_anom_2 = "res://scenes/Game/Background/ObjectScenes/fore_tree_anomoly_2.tscn"

var green_types: = [green1, green2, green3, green4, green5, green6, green7, green8] #array for normal obstacles
var active_green: Array
#var last_green

var fore_types: = [fbush1, fbush2, ftree1, ftree2]
var active_fore: Array
#var last_fore

var midpoint_green
var midpoint_fore
'''
func _ready():
	screen_size = get_window().size
	midpoint_green = $"green parallax".motion_mirroring / 2.0
	midpoint_fore = $"fore parallax".motion_mirroring / 2.0

func _process(delta):
	var camera_x = get_viewport().get_camera_2d().global_position.x
	
	# The scroll_offset is multiplied by the layer's motion_scale.
	var green_effective_pos_x = scroll_offset.x * $"green parallax".motion_scale.x
	var fore_effective_pos_x = scroll_offset.x * $"fore parallax".motion_scale.x
		 
	# Compare the camera's position relative to the layer's effective position.
	# If the camera's X position is a certain distance past the wrap boundary.
	if (camera_x - green_effective_pos_x) > midpoint_green:
		print("Camera has passed green parallax segment to the right.")
	if (camera_x - green_effective_pos_x) < -midpoint_green:
		print("Camera has passed green parallax parallax segment to the left.")
		
	if (camera_x - fore_effective_pos_x) > midpoint_fore:
		print("Camera has passed fore parallax segment to the right.")
	if (camera_x - fore_effective_pos_x) < -midpoint_fore:
		print("Camera has passed fore parallax parallax segment to the left.")
'''

'''
# !!! IF THIS DOESN'T WORK PUT SPRITE ON PARALLAX LAYER ITSELF
func _process(delta):
	#remove off screen
	for g in active_green:
		if g.position.x < ($Game.get_node("Camera2D").position.x - screen_size.x):
			remove_green(g)
	
	for f in active_fore:
		if f.position.x < ($Game.get_node("Camera2D").position.x - screen_size.x):
			remove_green(f)

func generate_obs():
	#genrerate green
	if active_green.is_empty() or last_green.position.x < $Game.get_node("Camera2D").position.x + randi_range(300,500): #instead of using timer, add obstacle once previous obstacle is psat a random point
		var green	
		#anom chances of appearing
		if randi()%20 == 0:
			green = green_anom_1.instantiate()
		elif randi()%50 == 0:
			green = green_anom_2.instantiate()
		else:
			green = green_types[randi() % green_types.size()].instantiate()
			
		#adding green
		var green_height = green.get_node("Sprite2D").texture.get_height() #asking for height of obs
		var green_scale = green.get_node("Sprite2D").scale
		var green_x: int = screen_size.x + get_parent().speed_change + 100 #+speed_change bc game is const moving to the left; +100 for buffer
		var green_y: int = screen_size.y - get_parent().ground_height - (green_height*green_scale.y /2) + 5
		add_green(green, green_x, green_y)
		last_green = green
			
	#generate fore
	if active_fore.is_empty() or last_fore.position.x < $Game.get_node("Camera2D").position.x + randi_range(300,500): #instead of using timer, add obstacle once previous obstacle is psat a random point
		var fore	
		#anom chances of appearing
		if randi()%20 == 0:
			fore = fore_anom_1.instantiate()
		elif randi()%50 == 0:
			fore = fore_anom_2.instantiate()
		else:
			fore = fore_types[randi() % fore_types.size()].instantiate()
			
		#adding fore
		var fore_height = fore.get_node("Sprite2D").texture.get_height() #asking for height of obs
		var fore_scale = fore.get_node("Sprite2D").scale
		#NEED TO GET THESE VARS FROM GAME NODE
		var fore_x: int = screen_size.x + get_parent().speed_change + 100 #+speed_change bc game is const moving to the left; +100 for buffer
		var fore_y: int = screen_size.y - get_parent().ground_height - (fore_height*fore_scale.y /2) + 5
		add_fore(fore, fore_x, fore_y)
		last_fore = fore

func add_green(green, x, y):
	green.position = Vector2i(x, y)
	add_child(green)
	active_green.append(green)
	
func remove_green(green):
	green.queue_free() #removes obstacle
	active_green.erase(green) #remove from array

func add_fore(fore, x, y):
	fore.position = Vector2i(x, y)
	add_child(fore)
	active_green.append(fore)
	
func remove_fore(fore):
	fore.queue_free() #removes obstacle
	active_fore.erase(fore) #remove from array
'''
