extends CharacterBody2D

const GRAVITY : int = 5000
const JUMP_SPEED : int = -1800
var combo_size : int = 2
var keys : Array = ["up", "down", "left", "right", "w", "s", "d", "a"]
var combo : Array = []
var released : bool = true

var accept_released = true
var left_released = true
var right_released = true

signal new_combo(combo)
signal move

func _ready():
	randomize()
	generate_combo()
	get_parent().connect("new_obstacle",generate_combo)

func generate_combo():
	combo.clear()
	var temp_keys = keys.duplicate()
	for i in range(combo_size):
		var rand_index = randi() % temp_keys.size()
		combo.append(temp_keys[rand_index])
		temp_keys.remove_at(rand_index)
	print("New combo:", combo)
	emit_signal("new_combo",combo)

func _physics_process(delta):
	velocity.y += GRAVITY * delta
	
	if Input.is_anything_pressed() and position.y > 746:
		
		if accept_released and Input.is_action_pressed("ui_accept"):
			accept_released = false
			velocity.y = JUMP_SPEED
			$AnimatedSprite2D.play("OLLIE")
		elif left_released and Input.is_action_pressed("ui_left"):
			left_released = false
			velocity.y = JUMP_SPEED
			$AnimatedSprite2D.play("KICKFLIP")
			move.emit("KICKFLIP")
		elif right_released and Input.is_action_pressed("ui_right"):
			right_released = false
			velocity.y = JUMP_SPEED
			$AnimatedSprite2D.play("OLLIE")
			move.emit("OLLIE")
	else:
		$AnimatedSprite2D.play("IDLE")
		
	if (!Input.is_action_pressed("ui_right") and !right_released):
		right_released = true
	if (!Input.is_action_pressed("ui_accept")):
		accept_released = true
	if (!Input.is_action_pressed("ui_left")):
		left_released = true
	
	'''
	if is_on_floor():
		if not get_parent().game_running:
			$AnimatedSprite2D.play("IDLE")
		else:
			if released:
				var all_pressed = true
				for key_name in combo:
					if not Input.is_action_pressed(key_name):
						all_pressed = false
						break
				
				if all_pressed:
					velocity.y = JUMP_SPEED
					released = false
					$AnimatedSprite2D.play("OLLIE")
				else:
					$AnimatedSprite2D.play("IDLE")
					$AnimatedSprite2D.play("IDLE")
			elif not Input.is_anything_pressed():
				released = true
			'''	
	move_and_slide()
