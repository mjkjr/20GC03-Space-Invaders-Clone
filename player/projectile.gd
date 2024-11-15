extends RigidBody2D

const SPEED: float = 1000.0
const DAMAGE: int = 25


func _physics_process(delta: float) -> void:
	move_and_collide(Vector2(0, -SPEED * delta))
	if position.y < 0:
		queue_free()


func get_damage() -> int:
	return DAMAGE
