extends CharacterBody2D

@export var speed = 75
@export var stopping_distance = 5

@onready var player = get_tree().get_first_node_in_group("player")

func _physics_process(_delta):
	chase_player()
	move_and_slide()

func chase_player():	
	var direction = global_position.direction_to(player.global_position)
	var distance_to_player = global_position.distance_to(player.global_position)
	
	if distance_to_player > stopping_distance:
		velocity = direction * speed
	else:
		velocity = Vector2.ZERO
