extends RigidBody2D

const SPEED: float = 250.0
const DAMAGE: int = 10

var exploding: bool = false


func _physics_process(delta: float) -> void:
	if exploding: return
	
	move_and_collide(Vector2(0, SPEED * delta))
	if position.y > get_viewport_rect().size.y:
		queue_free()


func get_damage() -> int:
	return DAMAGE


func _on_hit(body: Node) -> void:
	if body.get_groups().has("projectiles"):
		print("ENEMY PROJECTILE HIT! TODO: add SOUND effect")
		body.queue_free()
		$CollisionShape2D.set_deferred("disabled", true)
		$Projectile.visible = false
		$Destroyed.visible = true
		$Destroyed.play()
		exploding = true


func _on_destroyed_animation_finished() -> void:
	queue_free()
