extends Node

## A Space Invaders Clone

# TODO: Main menu
# TODO: Pause screen
# TODO: Game Over screen
# TODO: Ship to ship collision detection
# TODO: UI Sound Effects
# TODO: Bunkers
# TODO: Name
# TODO: Credits screen

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
			new_enemy.position.y = 3 * new_enemy.get_node("Ship").get_rect().size.y
			new_enemy.destroyed.connect(_on_enemy_destroyed)
	$Mothership.wait_time = randf_range(MOTHERSHIP_SPAWN_INTERVAL_MIN, MOTHERSHIP_SPAWN_INTERVAL_MAX)
	$Mothership.start()
	$Audio/Music.play()
	$Player.health_changed.connect(_on_player_health_changed)
	$Player.damaged.connect(_on_player_damaged)


func _on_player_damaged() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property($UI/Play/FlashDamage, "color", Color(1, 1, 1, 0.8), 0.1).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($UI/Play/FlashDamage, "color", Color(1, 1, 1, 0), 0.1)


func _on_player_health_changed(health: int) -> void:
	if health == 100:
		$UI/Play/Health/Meter.set_frame(3)
	elif health >= 80:
		$UI/Play/Health/Meter.set_frame(4)
	elif health >= 60:
		$UI/Play/Health/Meter.set_frame(5)
	elif health >= 40:
		$UI/Play/Health/Meter.set_frame(6)
	elif health >= 20:
		$UI/Play/Health/Meter.set_frame(7)
	else:
		$UI/Play/Health/Meter.set_frame(8)


func _on_enemy_destroyed() -> void:
	score += 100
	$UI/Play/Score/Score.text = str(score)


func _on_mothership_timeout() -> void:
	var mothership = MOTHERSHIP.instantiate()
	add_child(mothership)
	mothership.position.x = 0
	mothership.position.y = 1.5 * mothership.get_node("Ship").get_rect().size.y
	mothership.destroyed.connect(_on_mothership_destroyed)


func _on_mothership_destroyed() -> void:
	score += 500
	$UI/Play/Score/Score.text = str(score)
	$Mothership.wait_time = randf_range(MOTHERSHIP_SPAWN_INTERVAL_MIN, MOTHERSHIP_SPAWN_INTERVAL_MAX)
	$Mothership.start()
