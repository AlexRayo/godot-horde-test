class_name Player
extends CharacterBody2D
#TODO:
#Slow down the speed when player hovers some areas 

@export var speed : int = 250 

#Attacks
var iceBolt = preload("res://player/skills/iceBolt.tscn")

#Attack nodes
@onready var iceBoltDelayTimer : Timer = get_node("AttackIceBolt/IceBoltDelayTimer")
@onready var iceBoltSpeedTimer : Timer = get_node("AttackIceBolt/IceBoltDelayTimer/IceBoltSpeedTimer")


#icebolt
var icebolt_ammo: int = 0
var icebolt_baseammo: int = 1 #bolts by time(set in iceBoltSpeedTimer)
var icebolt_attackspeed: float = 1
var icebolt_level: int = 1

#enemy related
var enemies_in_range = []
var closest_enemies:Array = []

#field of view
var fov_increment = 2 * PI / 60 # to make the circle view area
@onready var space_state = get_world_2d().direct_space_state
#TODO: DRAW WITH CollisionPolygon2D
func _ready():
	attack()

func _process(_delta):
	var input_vector := Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")		
	)
	velocity = input_vector.normalized() * speed
	draw_target_area()
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
		return enemies_in_range.pick_random().global_position
	else :
		return Vector2.UP

#func _on_enemy_detection_area_body_entered(body):
#	if !enemies_in_range.has(body):
#		enemies_in_range.append(body)
#
#
#func _on_enemy_detection_area_body_exited(body):
#	if enemies_in_range.has(body):
#		enemies_in_range.erase(body)



#view area
func get_fov_circle(from: Vector2, radius):
	var angle = fov_increment
	var points : Array = []
	var raycast = RayCast2D.new()
	raycast.enabled = true
	while angle < 2 * PI:
		var offset = Vector2(radius, 0).rotated(angle)
		var to = from + offset
		raycast.to_global(to)
		raycast.global_position = from
		#from, to, [], 2
		var query = PhysicsRayQueryParameters2D.create(from, to)
		query.collision_mask = 1
		var result = space_state.intersect_ray(query)
		if result:
			points.append(result.position)
		else:
			points.append(to)
		angle += fov_increment
	return points

func draw_target_area():
	set_target_area(get_fov_circle(global_position, 300))
	
func set_target_area(points: Array):
	$TargetArea/Polygon2D.polygon = points
	
func clear_target_area():
	set_target_area([])
	
