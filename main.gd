extends Node

const ENEMY = preload("res://enemies/enemy.tscn")
const INITAL_ENEMY_COUNT = 50

var score: int = 0


func _ready() -> void:
	for i in range(0, INITAL_ENEMY_COUNT):
		get_tree().call_group("enemies", "move")
		var new_enemy = ENEMY.instantiate()
		add_child(new_enemy)
		new_enemy.killed.connect(_on_enemy_killed)


func _process(_delta: float) -> void:
	pass


func _on_enemy_timer_timeout() -> void:
	get_tree().call_group("enemies", "move")
	var new_enemy = ENEMY.instantiate()
	add_child(new_enemy)
	new_enemy.killed.connect(_on_enemy_killed)


func _on_enemy_killed() -> void:
	score += 100
	print("Score: %s" % score)
