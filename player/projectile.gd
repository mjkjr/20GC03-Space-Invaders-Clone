extends RigidBody2D

const SPEED: float = 1000.0


func _physics_process(delta: float) -> void:
	move_and_collide(Vector2(0, -SPEED * delta))
	if position.y < 0:
		queue_free()


func _on_hit(body: Node) -> void:
	if body.get_groups().has("projectiles"):
		print("hit by projectile!")
		print("TODO: add visual and sound effect")
		body.queue_free()
		queue_free()
