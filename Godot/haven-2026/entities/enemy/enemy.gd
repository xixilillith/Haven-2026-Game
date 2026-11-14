extends Area2D

var pencil_tscn = preload("res://entities/enemy/assets/pencil.png")
var player_vec: Vector2 = Vector2.ZERO
var velocity = 0
var on_screen = true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var rand_result = randi_range(0, 1)
	if rand_result == 0:
		$boy_sprite.visible = true
	else:
		$girl_sprite.visible = true


func _physics_process(delta: float) -> void:
	player_vec = (get_tree().current_scene.find_child("Player").global_position) - global_position
	while on_screen:
		velocity = player_vec
	
	global_position += velocity * delta


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	on_screen = false


#func _on_timer_timeout() -> void:
#	var new_pencil = pencil_tscn.instantiate()
#	new_pencil.global_position = global_position
#	new_pencil.velocity = player_vec
#	get_tree().current_scene.add_child(new_pencil)
