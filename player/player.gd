class_name Player
extends CharacterBody2D
#TODO:
#Slow down the speed when player hovers some areas 

@export var speed : int = 50 
@onready var anim:AnimatedSprite2D = $AnimatedSprite2D

#Attacks
var iceBolt = preload("res://player/skills/ice-bolt.tscn")

#Attack nodes
@onready var iceBoltDelayTimer : Timer = get_node("AttackIceBolt/IceBoltDelayTimer")
@onready var iceBoltSpeedTimer : Timer = get_node("AttackIceBolt/IceBoltDelayTimer/IceBoltSpeedTimer")

#icebolt
var icebolt_ammo: int = 0
var icebolt_baseammo: int = 5 #bolts by time
var icebolt_attackspeed: float = 1
var icebolt_level: int = 1

#enemy related
var enemies_in_range = []
var closest_enemies:Array = []

#field of view
var fov_increment = 2 * PI / 60 # to make the circle view area
@onready var space_state = get_world_2d().direct_space_state
var detection_cooldown: float = 0.5
const COOLDOWN:float = 0.5 
var target_area_drawn = false


func _ready():
	attack()
	
func _physics_process(_delta):
	var direction : Dictionary = {
		"x": Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		"y": Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	}
	var input_vector := Vector2(direction.x, direction.y)
	velocity = input_vector.normalized() * speed
	
	#change animation state
	if input_vector.x != 0 || input_vector.y != 0:
		anim.play("run")
	else:
		anim.play("idle")
		
	#flip horizontaly
	var isFacingRight = true
	if direction.x == 1:
		anim.flip_h = false
	if direction.x == -1:
		anim.flip_h = true
	
	move_and_slide()	
	# Solo dibuja el área si no se ha dibujado recientemente
	if not target_area_drawn and detection_cooldown <= 0:
		draw_target_area()
		target_area_drawn = true
		detection_cooldown = COOLDOWN  # Restablece el tiempo de enfriamiento
	else:
		if detection_cooldown > 0:
			detection_cooldown -= _delta
			target_area_drawn = false		
	$FPS_Counter.text = str(Engine.get_frames_per_second()) + " FPS"
	
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
		
#view area
func get_fov_circle(from: Vector2, radius):
	var angle = fov_increment
	var points : Array = []
	while angle < 2 * PI:
		var offset = Vector2(radius, 0).rotated(angle)
		var to = from + offset
		#from, to, [], 2
		var query = PhysicsRayQueryParameters2D.create(from, to)
		query.collision_mask = 1
		query.collide_with_bodies
		var result = space_state.intersect_ray(query)
		if result:
			points.append(result.position)
		else:
			points.append(to)
		angle += fov_increment
	self.set_z_index(1)
	return points
	#when trying do draw the polygon in some corners maybe you will get a NOT crashing error:
	#canvas_item_add_polygon: Invalid polygon data, tringulation failed
	#if cooldown to draw the polygon the more this error will appear

func draw_target_area():
	set_target_area(get_fov_circle(global_position, 300))	
	
func set_target_area(points: Array):
	$TargetArea/Polygon2D.polygon = points
	$TargetArea/CollisionPolygon2D.polygon = points	
	
func clear_target_area():
	set_target_area([])

func _on_target_area_body_entered(body):
	if not enemies_in_range.has(body):
		print(body)
		enemies_in_range.append(body)
		print("enemies_in_range: ",enemies_in_range.size())

func _on_target_area_body_exited(body):
	if enemies_in_range.has(body):
		enemies_in_range.erase(body)

# Esta función se utiliza para ordenar los enemigos por distancia
func _compare_enemies_by_distance(enemy_a, enemy_b):
	var distance_a = global_position.distance_to(enemy_a.global_position)
	var distance_b = global_position.distance_to(enemy_b.global_position)
	return distance_a - distance_b


func _on_timer_timeout():
	#draw_target_area()
	pass
