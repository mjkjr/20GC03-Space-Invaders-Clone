extends Node

## A Space Invaders Clone

# TODO: Health Meter
# TODO: Score display
# TODO: Main menu
# TODO: Pause screen
# TODO: Game Over screen
# TODO: UI Sound Effects
# TODO: Bunkers

enum State { PLAYING, PAUSED }

const ENEMY = preload("res://enemies/enemy.tscn")
const MOTHERSHIP = preload("res://enemies/mothership.tscn")
const MOTHERSHIP_SPAWN_INTERVAL_MIN = 10
const MOTHERSHIP_SPAWN_INTERVAL_MAX = 30

var state: State = State.PLAYING

var score: int = 0


func _ready() -> void:
	for i in range(0, 3):
		for n in range(0, 21):
			get_tree().call_group("enemies", "move")
			var new_enemy = ENEMY.instantiate()
			new_enemy.set_type(i)
			add_child(new_enemy)
			new_enemy.position.x = new_enemy.get_node("Ship").get_rect().size.x
			new_enemy.position.y = 2 * new_enemy.get_node("Ship").get_rect().size.y
			new_enemy.destroyed.connect(_on_enemy_destroyed)
	$Mothership.wait_time = randf_range(MOTHERSHIP_SPAWN_INTERVAL_MIN, MOTHERSHIP_SPAWN_INTERVAL_MAX)
	$Mothership.start()
	$Audio/Music.play()


func _on_enemy_destroyed() -> void:
	score += 100
	print("Score: %s" % score)


func _on_mothership_timeout() -> void:
	var mothership = MOTHERSHIP.instantiate()
	add_child(mothership)
	mothership.position.x = 0
	mothership.position.y = 0.5 * mothership.get_node("Ship").get_rect().size.y
	mothership.destroyed.connect(_on_mothership_destroyed)


func _on_mothership_destroyed() -> void:
	score += 500
	print("Score: %s" % score)
	$Mothership.wait_time = randf_range(MOTHERSHIP_SPAWN_INTERVAL_MIN, MOTHERSHIP_SPAWN_INTERVAL_MAX)
	$Mothership.start()
