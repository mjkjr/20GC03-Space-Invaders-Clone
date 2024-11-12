extends Area2D

const PROJECTILE = preload("res://player/projectile.tscn")
const SPEED: float = 700.0

var viewport: Rect2

var health: int = 100


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
	if position.x < viewport.position.x + ($Sprite2D.get_rect().size.x / 2):
		position.x = viewport.position.x + ($Sprite2D.get_rect().size.x / 2)
	elif position.x > viewport.end.x - $Sprite2D.get_rect().end.x:
		position.x = viewport.end.x - $Sprite2D.get_rect().end.x


func _viewport_resized() -> void:
	viewport = get_viewport_rect()


func _on_hit(body: Node2D) -> void:
	if body.get_groups().has("projectiles"):
		health -= body.get_damage()
		print("Health: %s" % health)
		print("TODO: add damage visual and sound effects")
		if health <= 0:
			print("dead!")
