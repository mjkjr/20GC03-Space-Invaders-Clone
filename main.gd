extends Node

## A Space Invaders Clone

# TODO: Main menu
# TODO: Pause screen
# TODO: Game Over screen
# TODO: Detect win condition (all enemies destroyed)
# TODO: UI Sound Effects
# TODO: Difficulty selection (make enemies faster / shoot more often)
# TODO: Bunkers
# TODO: Name
# TODO: Credits screen

enum State { PLAYING, PAUSED }

const ENEMY = preload("res://enemies/enemy.tscn")
const MOTHERSHIP = preload("res://enemies/mothership.tscn")
const MOTHERSHIP_SPAWN_INTERVAL_MIN = 5
const MOTHERSHIP_SPAWN_INTERVAL_MAX = 15

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
	$Player.damaged.connect(_on_player_damaged)
	$Player.destroyed.connect(_on_player_destroyed)


func game_over() -> void:
	print("game_over() function called.")
	$Mothership.stop()


func _check_win_condition() -> void:
	if get_tree().get_nodes_in_group("enemies").is_empty():
		print("Win condition met!")
		game_over()


func _on_player_damaged(new_health: int, max_health: int) -> void:
	# display a flash across the screen
	var tween = get_tree().create_tween()
	tween.tween_property($UI/Play/FlashDamage, "color", Color(1, 1, 1, 0.8), 0.1).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($UI/Play/FlashDamage, "color", Color(1, 1, 1, 0), 0.1)
	
	# update health meter
	var scaled_health: int = (new_health / (max_health / 5))
	match scaled_health:
		5:
			$UI/Play/Health/Meter.set_frame(3)
		4:
			$UI/Play/Health/Meter.set_frame(4)
		3:
			$UI/Play/Health/Meter.set_frame(5)
		2:
			$UI/Play/Health/Meter.set_frame(6)
		1:
			$UI/Play/Health/Meter.set_frame(7)
		_:
			$UI/Play/Health/Meter.set_frame(8)


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
	# wait until the end of the frame before checking win condition
	if not get_tree().process_frame.is_connected(_check_win_condition):
		get_tree().process_frame.connect(_check_win_condition, CONNECT_ONE_SHOT)


func _on_enemy_destroyed() -> void:
	score += 100
	$UI/Play/Score/Score.text = str(score)
	# wait until the end of the frame before checking win condition
	if not get_tree().process_frame.is_connected(_check_win_condition):
		get_tree().process_frame.connect(_check_win_condition, CONNECT_ONE_SHOT)


func _on_player_destroyed() -> void:
	game_over()
