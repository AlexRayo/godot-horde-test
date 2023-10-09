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
var icebolt_attackspeed: float = 2
var icebolt_level: int = 1

#enemy related
var enemy_close = []

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
	if enemy_close.size() > 0 :
		return enemy_close.pick_random().global_position
	else :
		return Vector2.UP

func _on_enemy_detection_area_body_entered(body):
	if not enemy_close.has(body):
		enemy_close.append(body)

#func get_closest_target():
#	if enemy_close.size() > 0:
#		var closest_enemy = []
#		for enemy in enemy_close:
#			closest_enemy.append(enemy.global_position.distance_to(global_position))
#		return enemy_close[closest_enemy.find(closest_enemy.min())].global_position
#	else:
#		return Vector2.DOWN


func _on_enemy_detection_area_body_exited(body):
	if enemy_close.has(body):
		enemy_close.erase(body)
