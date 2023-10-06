extends CharacterBody2D
#TODO:
#Slow down the speed when player hovers some areas 

@export var speed = 250 

func _process(_delta):
	var input_vector := Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")		
	)
	velocity = input_vector.normalized() * speed
	move_and_slide()
