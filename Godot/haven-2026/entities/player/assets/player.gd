extends CharacterBody2D

const MAX_DRAG = 200.0
const POWER = 1.5
var bouncing := false
var draggable := false
var dragging := false

func _physics_process(delta: float) -> void:
	print(draggable)
	if Input.is_action_pressed("drag") and draggable:
		dragging = true
	if Input.is_action_just_released("drag") and dragging:
		dragging = false
		var mouse_pos = get_global_mouse_position()
		var pull_vec = global_position - mouse_pos
		pull_vec = pull_vec.limit_length(MAX_DRAG)
		velocity = pull_vec * POWER

	global_position = global_position + (velocity * delta)
	move_and_slide()

func _on_drag_mouse_entered() -> void:
	if draggable != true:
		draggable = true


func _on_drag_mouse_exited() -> void:
	if draggable != false:
		draggable = false
