extends Node

## Star Defender
## A Space Invaders Clone

# TODO: Difficulty selection (make enemies faster / shoot more often)
# TODO: Bunkers


enum State { MAIN_MENU, PLAYING, PAUSED, GAME_OVER }

const PLAYER = preload("res://player/player.tscn")
const ENEMY = preload("res://enemies/enemy.tscn")
const MOTHERSHIP = preload("res://enemies/mothership.tscn")
const MOTHERSHIP_SPAWN_INTERVAL_MIN = 5
const MOTHERSHIP_SPAWN_INTERVAL_MAX = 15

var state: State = State.MAIN_MENU
var score: int = 0


func _ready() -> void:
	$Audio/Music.play()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Escape"):
		if $Menus/Credits.visible:
			_on_credits_dismiss_pressed()
		else:
			if state == State.PLAYING:
				_on_pause_pressed()
			elif state == State.PAUSED:
				_on_resume_pressed()


func start_game() -> void:
	state = State.PLAYING
	for i in range(0, 3):
		for n in range(0, 21):
			get_tree().call_group("enemies", "move")
			var new_enemy = ENEMY.instantiate()
			new_enemy.set_type(i)
			$Gameplay.add_child(new_enemy)
			new_enemy.position.x = new_enemy.get_node("Ship").get_rect().size.x
			new_enemy.position.y = 3 * new_enemy.get_node("Ship").get_rect().size.y
			new_enemy.destroyed.connect(_on_enemy_destroyed)
	$Gameplay/Mothership.wait_time = randf_range(MOTHERSHIP_SPAWN_INTERVAL_MIN, MOTHERSHIP_SPAWN_INTERVAL_MAX)
	$Gameplay/Mothership.start()
	var player = PLAYER.instantiate()
	$Gameplay.add_child(player)
	player.set_position(Vector2(294, 960))
	player.damaged.connect(_on_player_damaged)
	player.destroyed.connect(_on_player_destroyed)


func reset_game() -> void:
	get_tree().call_group("enemies", "free")
	get_tree().call_group("projectiles", "free")
	var player = get_node_or_null("Gameplay/Player")
	if player:
		$Gameplay/Player.free()
	$Gameplay/UI/Health/Meter/Inner.set_frame(3)
	_set_score(0)
	_resume_gameplay()


func game_over(win: bool = false) -> void:
	state = State.GAME_OVER
	_pause_gameplay()
	if win:
		$Menus/GameOver/CenterContainer/PanelContainer/VBoxContainer/Title.text = "You Win!"
	else:
		$Menus/GameOver/CenterContainer/PanelContainer/VBoxContainer/Title.text = "Game Over!"
	$Menus/GameOver.visible = true
	$Gameplay/Mothership.stop()


func _pause_gameplay() -> void:
	$Gameplay.process_mode = PROCESS_MODE_DISABLED


func _resume_gameplay() -> void:
	$Gameplay.process_mode = Node.PROCESS_MODE_INHERIT


func _set_score(new_score: int) -> void:
	score = new_score
	$Gameplay/UI/Score/Total.text = str(score)


func check_win_condition() -> void:
	if get_tree().get_nodes_in_group("enemies").is_empty():
		game_over(true)


func _check_win_condition() -> void:
	# wait until the end of the frame before checking win condition
	if not get_tree().process_frame.is_connected(check_win_condition):
		get_tree().process_frame.connect(check_win_condition, CONNECT_ONE_SHOT)


func _on_player_damaged(new_health: int, max_health: int) -> void:
	# display a flash across the screen
	var tween = get_tree().create_tween()
	tween.tween_property($Gameplay/UI/FlashDamage, "color", Color(1, 1, 1, 0.8), 0.1).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($Gameplay/UI/FlashDamage, "color", Color(1, 1, 1, 0), 0.1)
	
	# update health meter
	var scaled_health: int = (new_health / (max_health / 5))
	match scaled_health:
		5:
			$Gameplay/UI/Health/Meter/Inner.set_frame(3)
		4:
			$Gameplay/UI/Health/Meter/Inner.set_frame(4)
		3:
			$Gameplay/UI/Health/Meter/Inner.set_frame(5)
		2:
			$Gameplay/UI/Health/Meter/Inner.set_frame(6)
		1:
			$Gameplay/UI/Health/Meter/Inner.set_frame(7)
		_:
			$Gameplay/UI/Health/Meter/Inner.set_frame(8)


func _on_mothership_timeout() -> void:
	var mothership = MOTHERSHIP.instantiate()
	$Gameplay.add_child(mothership)
	mothership.position.x = 0
	mothership.position.y = 1.5 * mothership.get_node("Ship").get_rect().size.y
	mothership.destroyed.connect(_on_mothership_destroyed)
	mothership.gone.connect(_on_mothership_gone)


func _on_mothership_destroyed() -> void:
	_set_score(score + 500)
	_on_mothership_gone()


func _on_mothership_gone() -> void:
	$Gameplay/Mothership.wait_time = randf_range(MOTHERSHIP_SPAWN_INTERVAL_MIN, MOTHERSHIP_SPAWN_INTERVAL_MAX)
	$Gameplay/Mothership.start()
	_check_win_condition()


func _on_enemy_destroyed() -> void:
	_set_score(score + 100)
	_check_win_condition()


func _on_player_destroyed() -> void:
	game_over()


func _on_play_again_pressed() -> void:
	$Audio/Confirm.play()
	$Menus/GameOver.visible = false
	reset_game()
	start_game()


func _on_play_pressed() -> void:
	$Audio/Confirm.play()
	$Menus/Main.visible = false
	start_game()


func _on_pause_pressed() -> void:
	state = State.PAUSED
	$Audio/Confirm.play()
	$Menus/Pause.visible = true
	_pause_gameplay()


func _on_resume_pressed() -> void:
	state = State.PLAYING
	$Audio/Confirm.play()
	$Menus/Pause.visible = false
	_resume_gameplay()


func _on_credits_pressed() -> void:
	$Audio/Confirm.play()
	$Menus/Credits.visible = true


func _on_credits_dismiss_pressed() -> void:
	$Audio/Confirm.play()
	$Menus/Credits.visible = false
