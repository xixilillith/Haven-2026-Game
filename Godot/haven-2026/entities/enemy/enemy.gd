extends Area2D

var dead = false
var rand_result: int
var pencil_tscn = preload("res://entities/enemy/assets/pencil.tscn")
var player_vec: Vector2 = Vector2.ZERO
var velocity = 0
var on_screen = true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rand_result = randi_range(0, 1)
	if rand_result == 0:
		$boy_sprite.visible = true
	else:
		$girl_sprite.visible = true


func _physics_process(delta: float) -> void:
	if not dead:
		player_vec = (get_tree().current_scene.find_child("Player").global_position) - global_position
		if on_screen:
			print("sum")
			velocity = player_vec
		
		global_position += velocity * delta
		
		update_anim()


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	on_screen = false


func _on_timer_timeout() -> void:
	if not dead:
		var new_pencil = pencil_tscn.instantiate()
		new_pencil.global_position = global_position
		new_pencil.velocity = player_vec
		get_tree().current_scene.add_child(new_pencil)

func update_anim() -> void:
	if velocity != Vector2.ZERO:
		if rand_result == 1:
			$girl_sprite.play("default")
		elif rand_result == 0:
			$boy_sprite.play("default")
		if velocity.x < 0:
			if rand_result == 1:
				$girl_sprite.flip_h = true
			elif rand_result == 0:
				$boy_sprite.flip_h = true
		elif velocity.x > 0:
			if rand_result == 1:
				$girl_sprite.flip_h = false
			elif rand_result == 0:
				$boy_sprite.flip_h = false
		


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage") and body.bouncing:
		$girl_sprite.visible = false
		$boy_sprite.visible = false
		$flesh_sprite.visible = true
		dead = true
		print("hit")
