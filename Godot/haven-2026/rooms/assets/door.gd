extends Area2D
@export var size_x: float
@export var size_y: float
@export_enum("N","S","E","W") var door_direction: String = "E"#export enum sets the dropdown in inspector and allows you to check direction, second part defaults it to E

@onready var tween = get_tree().create_tween()
