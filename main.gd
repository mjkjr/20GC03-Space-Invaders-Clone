extends Node

const ENEMY = preload("res://enemies/enemy.tscn")
const MOTHERSHIP = preload("res://enemies/mothership.tscn")

var score: int = 0


func _ready() -> void:
	for i in range(0, 3):
		for n in range(0, 21):
			get_tree().call_group("enemies", "move")
			var new_enemy = ENEMY.instantiate()
			new_enemy.set_type(i)
			add_child(new_enemy)
			new_enemy.position.x = new_enemy.get_node("Sprite2D").get_rect().size.x
			new_enemy.position.y = 2 * new_enemy.get_node("Sprite2D").get_rect().size.y
			new_enemy.destroyed.connect(_on_enemy_destroyed)
	$Mothership.wait_time = randf_range(0, 1)
	$Mothership.start()


func _on_enemy_destroyed() -> void:
	score += 100
	print("Score: %s" % score)


func _on_mothership_timeout() -> void:
	var mothership = MOTHERSHIP.instantiate()
	add_child(mothership)
	mothership.position.x = -mothership.get_node("Sprite2D").get_rect().size.x
	mothership.position.y = 0.5 * mothership.get_node("Sprite2D").get_rect().size.y
	mothership.destroyed.connect(_on_mothership_destroyed)


func _on_mothership_destroyed() -> void:
	$Mothership.wait_time = randf_range(30, 90)
	$Mothership.start()
