class_name EnemySpawner
extends Node2D

@export var spawns: Array[SpawnResource] = []

@onready var player = get_tree().get_first_node_in_group("player")

var time = 0

func _on_timer_timeout():
	time += 1
	var enemySpawns = spawns
	for enemy in enemySpawns:
		if time >= enemy.timeStart and time <= enemy.timeEnd:
			if enemy.spawnDelayCounter < enemy.enemySpawnDelay:
				enemy.spawnDelayCounter += 1
			else:
				enemy.spawnDelayCounter = 0
				var newEnemy = enemy.enemy
				var counter = 0
				while counter < enemy.enemyQty:
					var enemySpawn = newEnemy.instantiate()
					enemySpawn.global_position = await get_random_position()
					add_child(enemySpawn)
					counter += 1
				
func get_random_position():
	var viewport = get_viewport_rect().size * randf_range(1.1, 1.4) # Obtener el tamaño de la vista aleatoriamente entre estos argumentos
	
	var topLeft = Vector2(player.global_position.x - viewport.x / 2, player.global_position.y - viewport.y / 2)
	var topRight = Vector2(player.global_position.x + viewport.x / 2, player.global_position.y - viewport.y / 2)
	var bottomRight = Vector2(player.global_position.x + viewport.x / 2, player.global_position.y + viewport.y / 2)
	var bottomLeft = Vector2(player.global_position.x - viewport.x / 2, player.global_position.y + viewport.y / 2)
	
	var pickSide = ["up", "right", "down", "left"].pick_random()
	var position1 = Vector2.ZERO
	var position2 = Vector2.ZERO
	
	match pickSide:
		"up":
			position1 = topLeft
			position2 = topRight
		"down":
			position1 = bottomLeft
			position2 = bottomRight
		"right":
			position1 = topRight
			position2 = bottomRight
		"left":
			position1 = topLeft
			position2 = bottomLeft
	
	var xSpawn = randf_range(position1.x, position2.x)
	var ySpawn = randf_range(position1.y, position2.y)
	
	var spawnPosition = Vector2(xSpawn, ySpawn)
	
	# Comprobar si la posición de generación está dentro de la capa de las paredes
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.new()
	query.from = player.global_position
	query.to = spawnPosition
	query.collision_mask = 1
	var result = space_state.intersect_ray(query)
	
	if result:
		await get_tree().create_timer(1).timeout #`await` to avoid recursion
		return await get_random_position()
		print("Si el resultado--->", result)
	else:
		print("ENEMIGO GENERADO")
		return spawnPosition
		# La posición de generación está dentro de la capa de las paredes, intentar de nuevo
