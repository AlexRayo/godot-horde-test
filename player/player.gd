class_name Player
extends CharacterBody2D
#TODO:
#Slow down the speed when player hovers some areas 

@export var speed : int = 250 

#Attacks
var iceBolt = preload("res://player/skills/ice-bolt.tscn")

#Attack nodes
@onready var iceBoltDelayTimer : Timer = get_node("AttackIceBolt/IceBoltDelayTimer")
@onready var iceBoltSpeedTimer : Timer = get_node("AttackIceBolt/IceBoltDelayTimer/IceBoltSpeedTimer")

#icebolt
var icebolt_ammo: int = 0
var icebolt_baseammo: int = 1
var icebolt_attackspeed: float = 1
var icebolt_level: int = 1

#enemy related
var enemies_in_range = []
var closest_enemies:Array = []

func _ready():
	attack()

func _process(_delta):
	var input_vector := Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")		
	)
	velocity = input_vector.normalized() * speed
	move_and_slide()

func attack():
	if icebolt_level > 0:
		iceBoltDelayTimer.wait_time = icebolt_attackspeed
		if iceBoltDelayTimer.is_stopped():
			iceBoltDelayTimer.start()
			

func _on_ice_bolt_delay_timer_timeout():
	icebolt_ammo += icebolt_baseammo
	iceBoltSpeedTimer.start()

func _on_ice_bolt_speed_timeout():
	if icebolt_ammo > 0:
		var newIceBolt = iceBolt.instantiate()
		newIceBolt.position = position
		newIceBolt.target = get_random_target()
		newIceBolt.level = icebolt_level
		add_child(newIceBolt)
		icebolt_ammo -= 1
		if icebolt_ammo > 0:
			iceBoltDelayTimer.start()
		else:
			iceBoltSpeedTimer.stop()
		

func get_random_target():
	if enemies_in_range.size() > 0 :
		var pick_enemy = enemies_in_range.pick_random()
		var pick_position = pick_enemy.global_position#here tries to pick an erased element
		#enemies_in_range.erase(pick_enemy)
		return pick_position
	else :
		return Vector2.UP

func _on_enemy_detection_area_body_entered(body):
	if !enemies_in_range.has(body):
		enemies_in_range.append(body)

func get_closest_target() -> Vector2:
	var closest_position: Vector2
	#### WORKING ####
	if enemies_in_range.size() > 0:
		var enemies_distance = []
		for enemy in enemies_in_range:
			enemies_distance.append(enemy.global_position)
		var min_distance = closest_enemies.min()
		var min_index = closest_enemies.find(min_distance)
		var idx_min = 0
		for i in range(1,len(enemies_distance)):
			if enemies_distance[i] < enemies_distance[idx_min]:
				idx_min = i
		var closest: CharacterBody2D = enemies_in_range[idx_min]
		print("idx_min: ", idx_min)
		closest_position = closest.global_position
		return closest_position
	else:
		return Vector2.DOWN



func _on_enemy_detection_area_body_exited(body):
	pass
#	print("Enemy eliminated: ", body)
#	if enemies_in_range.has(body):
#		enemies_in_range.erase(body)
