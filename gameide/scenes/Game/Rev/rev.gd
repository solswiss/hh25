extends CharacterBody2D

const GRAVITY : int = 4200
const JUMP_SPEED : int = -1800
var combo_size : int = 2
var keys : Array = ["up", "down", "left", "right", "w", "s", "d", "a"]
var combo : Array = []
var released : bool = true

func _ready():
	randomize()
	generate_combo()

func generate_combo():
	combo.clear()
	var temp_keys = keys.duplicate()
	for i in range(combo_size):
		var rand_index = randi() % temp_keys.size()
		combo.append(temp_keys[rand_index])
		temp_keys.remove_at(rand_index)
	print("New combo:", combo)

func _physics_process(delta):
	velocity.y += GRAVITY * delta

	if is_on_floor():
		if not get_parent().game_running:
			$AnimatedSprite2D.play("idle")
		else:
			$RunCol.disabled = false

			if released:
				var all_pressed = true
				for key_name in combo:
					if not Input.is_action_pressed(key_name):
						all_pressed = false
						break
				
				if all_pressed:
					velocity.y = JUMP_SPEED
					released = false
					$AnimatedSprite2D.play("jump")
					generate_combo()
				else:
					$AnimatedSprite2D.play("idle")
			elif not Input.is_anything_pressed():
				released = true

	move_and_slide()
