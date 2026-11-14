extends CharacterBody2D

const FRICTION = 1
@export var drag_line: Line2D
const MAX_DRAG = 200.0
const POWER = 1.5
var bouncing := false
var draggable := false
var dragging := false

func _ready() -> void:
	drag_line.visible = false

func _physics_process(delta: float) -> void:
	print(draggable)
	var mouse_pos = get_global_mouse_position()
	var pull_vec = global_position - mouse_pos
	var drag_vec = mouse_pos - global_position
	var line_max = drag_vec.limit_length(MAX_DRAG)
	drag_line.set_point_position(0, global_position)
	drag_line.set_point_position(1, (global_position + line_max))
	if Input.is_action_pressed("drag") and draggable:
		dragging = true
		drag_line.visible = true
		velocity = Vector2.ZERO
	if Input.is_action_just_released("drag") and dragging:
		dragging = false
		drag_line.visible = false
		pull_vec = pull_vec.limit_length(MAX_DRAG)
		velocity = pull_vec * POWER
	velocity.x = move_toward(velocity.x, 0, FRICTION)
	velocity.y = move_toward(velocity.y, 0, FRICTION)

	global_position = global_position + (velocity * delta)
	move_and_slide()

func _on_drag_mouse_entered() -> void:
	if draggable != true:
		draggable = true


func _on_drag_mouse_exited() -> void:
	if draggable != false:
		draggable = false
