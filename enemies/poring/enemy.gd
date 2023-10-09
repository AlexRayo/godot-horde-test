extends CharacterBody2D

@export var speed = 75
@export var stopping_distance = 10

var maxDistanceFromObject = 50

@onready var player : Node2D = get_tree().get_first_node_in_group("player")
@onready var nav_agent := $NavigationAgent2D as NavigationAgent2D

func _physics_process(_delta: float) -> void:
	chase_player()
	move_and_slide()
	
func chase_player() -> void:	
	var distance_to_player = global_position.distance_to(player.global_position)
	#var dir = global_position.direction_to(player.global_position)
	
	var dir = to_local(nav_agent.get_next_path_position()).normalized()
	
	#velocity = dir * speed
	if distance_to_player > stopping_distance:
		velocity = dir * speed
	else:
		velocity = Vector2.ZERO

func makepath()->void:
	nav_agent.target_position = player.global_position

func _on_timer_timeout():
	makepath()
