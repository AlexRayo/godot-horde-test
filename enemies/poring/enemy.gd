extends CharacterBody2D

@export var speed = 75
@export var stopping_distance = 10
var max_distance_from_object = 50

@onready var player := get_tree().get_first_node_in_group("player")

@onready var raycast_top := $RaycastTop
@onready var raycast_right_top := $RaycastRightTop
@onready var raycast_right_center := $RaycastRightCenter
@onready var raycast_right_bottom := $RaycastRightBottom
@onready var raycast_bottom := $RaycastBottom
@onready var raycast_left_top := $RaycastLeftTop
@onready var raycast_left_center := $RaycastLeftCenter
@onready var raycast_left_bottom := $RaycastLeftBottom

func _physics_process(delta) -> void:
	chase_player()
	move_and_slide()

func chase_player() -> void:
	var distance_to_player = global_position.distance_to(player.global_position)
	var dir = global_position.direction_to(player.global_position)

	if distance_to_player > stopping_distance:
		var adjusted_direction = adjust_direction_to_avoid_obstacle(dir)
		velocity = adjusted_direction * speed
	else:
		velocity = Vector2.ZERO

func adjust_direction_to_avoid_obstacle(direction: Vector2) -> Vector2:
	var adjusted_direction = direction

	# Verificar cuál de los raycasts está bloqueado y en qué dirección moverse
	if raycast_top.is_colliding():
		adjusted_direction.x = 0
		adjusted_direction.y = 1
	
	if raycast_right_top.is_colliding() || raycast_right_center.is_colliding() || raycast_right_bottom.is_colliding():
		adjusted_direction.x = 0
		adjusted_direction.y = 1

	if raycast_bottom.is_colliding():
		adjusted_direction.x = 0
		adjusted_direction.y = -1

	if raycast_left_top.is_colliding() || raycast_left_center.is_colliding() || raycast_left_bottom.is_colliding():
		adjusted_direction.x = 1
		adjusted_direction.y = 0

	return adjusted_direction.normalized()
