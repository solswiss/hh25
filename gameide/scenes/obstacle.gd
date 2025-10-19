extends Area2D

enum ObstacleType {

}

@export var type: ObstacleType

signal hit(body: Node)

func _ready():
	#add to obstacles group
	add_to_group("obstacles")
	connect("body_entered", _on_body_entered)

func _on_body_entered(body: Node):
	emit_signal("hit", body)
