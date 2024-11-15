extends Area2D

signal destroyed

enum Direction { LEFT, RIGHT }

const PROJECTILE = preload("res://enemies/mothership-projectile.tscn")
const PROJECTILE_DELAY_MIN: int = 1
const PROJECTILE_DELAY_MAX: int = 5
const PROJECTILE_COUNT: int = 3

var movement_direction: Direction = Direction.RIGHT

# how many projectiles have been shot in a single go so far
var projectiles_shot: int = 0

var health: int = 100
var exploding: bool = false


func _ready() -> void:
	# randomize the shooting timer
	$Timers/Shoot.wait_time = randf_range(PROJECTILE_DELAY_MIN, PROJECTILE_DELAY_MAX)
	$Timers/Shoot.start()
	$Audio/Ambient.play()


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
	$Audio/Shoot.play()
	projectiles_shot += 1
	if projectiles_shot < PROJECTILE_COUNT:
		$Timers/Shoot.wait_time = 0.25
	else:
		projectiles_shot = 0
		$Timers/Shoot.wait_time = randf_range(PROJECTILE_DELAY_MIN, PROJECTILE_DELAY_MAX)
	$Timers/Shoot.start()


func _on_hit(body: Node2D) -> void:
	if body.get_groups().has("projectiles"):
		health -= body.get_damage()
		body.queue_free()
		#print("MOTHERSHIP HIT (Health: %s)!" % health)
		if health <= 0:
			destroyed.emit()
			$CollisionShape2D.set_deferred("disabled", true)
			$Ship.visible = false
			$Animations/Destroyed.visible = true
			$Animations/Destroyed.play()
			$Audio/Destroyed.play()
			exploding = true
		else:
			$Animations/Hit.visible = true
			$Animations/Hit.play()
			$Audio/Damage.play()


func _on_hit_animation_finished() -> void:
	$Animations/Hit.visible = false


func _on_destroyed_animation_finished() -> void:
	queue_free()
