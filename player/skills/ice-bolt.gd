extends Area2D

var level = 1
var hp = 1
var speed = 200
var damage = 1
var knock_amount = 100
var attack_size = 1.0

var target: Vector2 = Vector2.ZERO
var target_position: Vector2 = Vector2.ZERO

@onready var player: Player = get_tree().get_first_node_in_group("player")
#signal remove_from_array(object)

#NOTE: The area2D in "visibility" from the inspector needs to set as "Top Level". 
##This will make sure to draw our sprite at the top index

func _ready():
	target_position = global_position.direction_to(target)
	rotation = target_position.angle() * deg_to_rad(135)
	match level:
		1:
			hp = 1
			speed = 800
			damage = 1
			knock_amount = 100
			attack_size = 0.2
			
	#use tween to alternate node values properties
	#var tween = create_tween().set_parallel(true)#set_parallel(true) if you want to run several tweens
	#tween.tween_property(self, "scale", Vector2(1,1) * attack_size, 1).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	#set the tween(the node, name of the value, set the value of the end result, the time to take this change)
	#tween.chain() to separete a node from the parallel state
	#tween.tween_callback(Callable(self, "_on_timer_timeout")) if you want to use a timer node
	#tween.play()
	
func _physics_process(delta):
	position += target_position * speed * delta
	
func enemy_hit(charge = 1):
	hp -= charge
	if hp <= 0 :
		#emit_signal("remove_from_array",self)
		queue_free()



func _on_body_entered(body):
	if body.is_in_group("enemy"):
		player.enemies_in_range.erase(body)
		player.closest_enemies.erase(body)
		#print("Enemi hit with ice bolt")
		body.queue_free()
		queue_free()
	pass # Replace with function body.


func _on_timer_timeout():
	#emit_signal("remove_from_array",self)
	queue_free()
