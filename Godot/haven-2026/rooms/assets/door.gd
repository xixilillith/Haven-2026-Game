extends Area2D
@export var size_x: float
@export var size_y: float
@export_enum("N","S","E","W") var door_direction: String = "E"#export enum sets the dropdown in inspector and allows you to check direction, second part defaults it to E

@onready var tween = get_tree().create_tween()
func _ready() -> void:#godot always automatically calls it when door is added
	$CollisionShape2D.scale.x = size_x
	$CollisionShape2D.scale.y = size_y
	body_entered.connect(_on_body_entered)
	# Handles rooms where CharacterBody2D is already saved inside the scene
	#if GameManager.entry_direction == door_direction:
		#for child in get_parent().get_children():
			#if child is CharacterBody2D:
			#	GameManager.entry_direction = ""
			#	play_entry_walk(child)
			#	break
func play_entry_walk(player: CharacterBody2D) -> void:
	var start_marker := get_node_or_null("Start")
	var spawn_marker := get_node_or_null("Spawn")

	player.global_position = start_marker.global_position if start_marker else global_position
	if spawn_marker == null:
		return

	$CollisionShape2D.set_deferred("disabled", true)
	tween = get_tree().create_tween()
	tween.tween_property(player, "global_position", spawn_marker.global_position, 0.4)
	tween.tween_callback(func(): $CollisionShape2D.disabled = false)
func _on_body_entered(body: Node2D) -> void: #called when touching door
	if body is CharacterBody2D:#checks if its a 2d body
		print("DOOR")
