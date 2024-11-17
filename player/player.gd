extends Area2D

signal damaged(new_health: int, max_health: int)
signal destroyed

const MAX_HEALTH = 5
const PROJECTILE = preload("res://player/projectile.tscn")
const SPEED: float = 700.0

var viewport: Rect2

var health: int = MAX_HEALTH
var exploding: bool = false
var gun_ready: bool = true


func _ready() -> void:
	_viewport_resized()
	get_tree().get_root().size_changed.connect(_viewport_resized)


func _process(delta: float) -> void:
	if Input.is_action_pressed("Move Left"):
		position.x -= SPEED * delta
	elif Input.is_action_pressed("Move Right"):
		position.x += SPEED * delta
	
	# restrict to viewport:
	if position.x < viewport.position.x + ($Ship.get_rect().size.x * 0.5) + 6:
		position.x = viewport.position.x + ($Ship.get_rect().size.x * 0.5) + 6
	elif position.x > viewport.end.x - $Ship.get_rect().end.x - 6:
		position.x = viewport.end.x - $Ship.get_rect().end.x - 6
	
	if (
			Input.is_action_just_pressed("Shoot")
			and gun_ready
	):
		gun_ready = false
		$ShootCooldown.start()
		var projectile = PROJECTILE.instantiate()
		projectile.position.x = global_position.x
		projectile.position.y = global_position.y - 30
		add_sibling(projectile)
		$Audio/Shoot.play()


func destroy() -> void:
	$CollisionShape2D.set_deferred("disabled", true)
	$Ship.visible = false
	$Animations/Destroyed.visible = true
	$Animations/Destroyed.play()
	$Audio/Destroyed.play()
	exploding = true

func _viewport_resized() -> void:
	viewport = get_viewport_rect()


func _on_hit(body: Node2D) -> void:
	if body.get_groups().has("projectiles"):
		health -= body.get_damage()
		damaged.emit(health, MAX_HEALTH)
		if health <= 0:
			destroy()
		else:
			#print("DAMAGE TAKEN (%s health remaining)!" % health)
			if body.get_damage_type() == "Electrical":
				$Animations/ElectricalDamage.visible = true
				$Animations/ElectricalDamage.play()
				$Audio/ElectricalDamage.play()
			else:
				$Animations/KineticDamage.global_position.x = body.position.x
				$Animations/KineticDamage.visible = true
				$Animations/KineticDamage.play()
				$Audio/KineticDamage.play()


func _on_kinetic_damage_animation_finished() -> void:
	$Animations/KineticDamage.visible = false


func _on_electrical_damage_animation_finished() -> void:
	$Animations/ElectricalDamage.visible = false


func _on_destroyed_animation_finished() -> void:
	destroyed.emit()


func _on_area_entered(area: Area2D) -> void:
	if area.get_groups().has("enemies"):
		health = 0
		damaged.emit(health, MAX_HEALTH)
		destroy()


func _on_shoot_cooldown_timeout() -> void:
	gun_ready = true
