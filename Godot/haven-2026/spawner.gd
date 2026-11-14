extends Node2D

var enemy_tscn = preload("res://entities/enemy/enemy.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.

func _on_timer_timeout() -> void:
	var enemy = enemy_tscn.instantiate()
	enemy.global_position = global_position
	get_tree().current_scene.add_child(enemy)
