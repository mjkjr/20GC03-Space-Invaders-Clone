extends Area2D

signal destroyed

enum Direction { LEFT, RIGHT }

const PROJECTILE = preload("res://enemies/mothership-projectile.tscn")
const PROJECTILE_LOAD: int = 6

var movement_direction: Direction = Direction.RIGHT

# how many projectiles have been shot in a single go so far
var projectile_load: int = 0

var health: int = 100
var exploding: bool = false


func _ready() -> void:
	# randomize the shooting timer
	$Shoot.wait_time = randf_range(1, 5)
	$Shoot.start()


func _on_move_timeout() -> void:
	if exploding: return
	
	if movement_direction == Direction.LEFT:
		if position.x == 0:
			movement_direction = Direction.RIGHT
		else:
			position.x -= $Ship.get_rect().size.x
	else:
		if position.x == get_viewport_rect().size.x - $Ship.get_rect().size.x:
			movement_direction = Direction.LEFT
		else:
			position.x += $Ship.get_rect().size.x


func _on_shoot_timeout() -> void:
	var projectile = PROJECTILE.instantiate()
	projectile.position.x = global_position.x + 48
	projectile.position.y = global_position.y + 24
	add_sibling(projectile)
	if projectile_load <= PROJECTILE_LOAD:
		projectile_load += 1
		$Shoot.wait_time = 0.25
	else:
		projectile_load = 0
		$Shoot.wait_time = randf_range(1, 5)
	$Shoot.start()


func _on_hit(body: Node2D) -> void:
	if body.get_groups().has("projectiles"):
		health -= body.get_damage()
		body.queue_free()
		print("MOTHERSHIP HIT (Health: %s)!" % health)
		if health <= 0:
			print("MOTHERSHIP DESTROYED! TODO: add sound effect!")
			destroyed.emit()
			$CollisionShape2D.set_deferred("disabled", true)
			$Ship.visible = false
			$Destroyed.visible = true
			$Destroyed.play()
			exploding = true
		else:
			$Hit.visible = true
			$Hit.play()


func _on_hit_animation_finished() -> void:
	$Hit.visible = false


func _on_destroyed_animation_finished() -> void:
	queue_free()
