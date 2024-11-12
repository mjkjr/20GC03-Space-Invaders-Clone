extends RigidBody2D

const SPEED: float = 250.0
const DAMAGE: int = 10


func _physics_process(delta: float) -> void:
	move_and_collide(Vector2(0, SPEED * delta))
	if position.y > get_viewport_rect().size.y:
		queue_free()


func get_damage() -> int:
	return DAMAGE
