extends Area2D

var level = 1
var hp = 1
var speed = 200
var damage = 5
var knock_amount = 100
var attack_size = 1.0

var target: Vector2 = Vector2.ZERO
var target_position: Vector2 = Vector2.ZERO

@onready var player: Node2D = get_tree().get_first_node_in_group("player")
#signal remove_from_array(object)

#NOTE: The area2D in "visibility" from the inspector needs to set as "Top Level". 
##This will make sure to draw our sprite at the top index

func _ready():
	target_position = global_position.direction_to(target)
	print("target_position.angle(): ", target_position.angle())
	rotation = target_position.angle() * deg_to_rad(target_position.angle())
	match level:
		1:
			hp = 1
			speed = 200
			damage = 5
			knock_amount = 100
			attack_size = 1.0

func _physics_process(delta):
	position += target_position * speed * delta
	
func enemy_hit(charge = 1):
	hp -= charge
	if hp <= 0 :
		emit_signal("remove_from_array",self)
		queue_free()

func _on_timer_timeout():
	emit_signal("remove_from_array",self)
	queue_free()
