extends CharacterBody2D

const FRICTION = 0.3
@export var drag_line: Line2D
const MAX_DRAG = 200.0
const POWER = 2.5
var bouncing := false
var draggable := false
var dragging := false

func _ready() -> void:
	drag_line.visible = false

func _physics_process(delta: float) -> void:
	var collision: KinematicCollision2D = move_and_collide(velocity * delta)
	
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
		
	if collision:
		velocity = velocity.bounce(collision.get_normal())
	else:	
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION)
	
	animation_update()

func _on_drag_mouse_entered() -> void:
	if draggable != true:
		draggable = true


func _on_drag_mouse_exited() -> void:
	if draggable != false:
		draggable = false

func animation_update() -> void:
	if velocity == Vector2.ZERO:
		$Face.animation = "default"
		$Face.flip_h = false
		$Face.flip_v = false
		$Face.play()
	else:
		if abs(velocity.x) > abs(velocity.y):
			$Face.animation = "roll_h"
			$Face.flip_h = true if velocity.x < 0 else false
			$Face.play()
		else:
			$Face.animation = "roll_v"
			$Face.flip_v = true if velocity.y > 0 else false
			$Face.play()
