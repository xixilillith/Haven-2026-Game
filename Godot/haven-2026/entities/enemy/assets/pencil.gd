extends Area2D

var velocity: Vector2
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	global_position += velocity * delta
	await get_tree().create_timer(1).timeout
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage") and body.bouncing != true:
		body.take_damage(100)
