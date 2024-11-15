extends Area2D

const PROJECTILE = preload("res://player/projectile.tscn")
const SPEED: float = 700.0

var viewport: Rect2

var health: int = 100
var exploding: bool = false


func _ready() -> void:
	_viewport_resized()
	get_tree().get_root().size_changed.connect(_viewport_resized)


func _process(delta: float) -> void:
	if Input.is_action_pressed("Move Left"):
		position.x -= SPEED * delta
	elif Input.is_action_pressed("Move Right"):
		position.x += SPEED * delta
	
	if Input.is_action_just_pressed("Shoot"):
		var projectile = PROJECTILE.instantiate()
		projectile.position.x = global_position.x
		projectile.position.y = global_position.y - 30
		add_sibling(projectile)
	
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
			print("DIED!  TODO: Add SOUND effect")
			$CollisionShape2D.set_deferred("disabled", true)
			$Ship.visible = false
			$Destroyed.visible = true
			$Destroyed.play()
			exploding = true
		else:
			print("DAMAGE TAKEN (%s health remaining)!  TODO: add SOUND effect" % health)
			if body.get_groups().has("mothership"):
				$Hit2.visible = true
				$Hit2.play()
			else:
				$Hit.global_position.x = body.position.x
				$Hit.visible = true
				$Hit.play()


func _on_hit_animation_finished() -> void:
	$Hit.visible = false


func _on_hit_2_animation_finished() -> void:
	$Hit2.visible = false


func _on_destroyed_animation_finished() -> void:
	print("TODO: GAME OVER!")
