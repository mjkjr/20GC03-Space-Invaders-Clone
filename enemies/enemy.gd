extends Area2D

signal destroyed

enum Direction { LEFT, RIGHT }

const PROJECTILE = preload("res://enemies/projectile.tscn")

var movement_direction: Direction = Direction.RIGHT

var exploding: bool = false


func _ready() -> void:
	# randomize the shooting timer
	$Shoot.wait_time = randf_range(1, 120)
	$Shoot.start()


func set_type(which: int) -> void:
	$Ship.frame = which


func move() -> void:
	if exploding: return
	
	if movement_direction == Direction.LEFT:
		if position.x == $Ship.get_rect().size.x:
			position.y += $Ship.get_rect().size.y
			movement_direction = Direction.RIGHT
		else:
			position.x -= $Ship.get_rect().size.x
	else:
		if position.x == get_viewport_rect().size.x - ($Ship.get_rect().size.x * 2):
			position.y += $Ship.get_rect().size.y
			movement_direction = Direction.LEFT
		else:
			position.x += $Ship.get_rect().size.x


func _on_move_timeout() -> void:
	move()


func _on_shoot_timeout() -> void:
	var projectile = PROJECTILE.instantiate()
	projectile.position.x = global_position.x + 33
	projectile.position.y = global_position.y + 21
	add_sibling(projectile)
	$Shoot.wait_time = randf_range(1, 120)
	$Shoot.start()


func _on_hit(body: Node2D) -> void:
	if body.get_groups().has("projectiles"):
		print("ENEMY SHIP DESTROYED!  TODO: add SOUND effect!")
		destroyed.emit()
		$CollisionShape2D.set_deferred("disabled", true)
		$Ship.visible = false
		$Destroyed.visible = true
		$Destroyed.play()
		exploding = true
		body.queue_free()


func _on_destroyed_animation_finished() -> void:
	queue_free()
