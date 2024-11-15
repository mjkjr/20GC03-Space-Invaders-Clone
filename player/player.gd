extends Area2D

const PROJECTILE = preload("res://player/projectile.tscn")
const SPEED: float = 700.0
const COOLDOWN: float = 0.5

var viewport: Rect2

var health: int = 100
var exploding: bool = false
var cooldown: float = 0


func _ready() -> void:
	_viewport_resized()
	get_tree().get_root().size_changed.connect(_viewport_resized)


func _process(delta: float) -> void:
	if Input.is_action_pressed("Move Left"):
		position.x -= SPEED * delta
	elif Input.is_action_pressed("Move Right"):
		position.x += SPEED * delta

	if cooldown > 0:
		cooldown -= delta
	else:
		if Input.is_action_just_pressed("Shoot"):
			cooldown = COOLDOWN
			var projectile = PROJECTILE.instantiate()
			projectile.position.x = global_position.x
			projectile.position.y = global_position.y - 30
			add_sibling(projectile)
			$Audio/Shoot.play()
	
	# restrict to viewport:
	if position.x < viewport.position.x + ($Ship.get_rect().size.x / 2):
		position.x = viewport.position.x + ($Ship.get_rect().size.x / 2)
	elif position.x > viewport.end.x - $Ship.get_rect().end.x:
		position.x = viewport.end.x - $Ship.get_rect().end.x


func _viewport_resized() -> void:
	viewport = get_viewport_rect()


func _on_hit(body: Node2D) -> void:
	if body.get_groups().has("projectiles"):
		health -= body.get_damage()
		if health <= 0:
			$CollisionShape2D.set_deferred("disabled", true)
			$Ship.visible = false
			$Animations/Destroyed.visible = true
			$Animations/Destroyed.play()
			$Audio/Destroyed.play()
			exploding = true
		else:
			print("DAMAGE TAKEN (%s health remaining)!" % health)
			if body.get_groups().has("mothership"):
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
	print("TODO: GAME OVER!")
