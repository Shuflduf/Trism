@icon("res://Assets/Editor/component3d.png")

class_name HoldPiece3D
extends GridMap

@export var base: HoldPiece
@export var offset: Vector3i

func convert_vec2_vec3(vec2 : Vector2i) -> Vector3i:
	return Vector3i(vec2.x, -vec2.y, 0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	base.update.connect(func() -> void:
		draw())

func draw() -> void:
	clear()
	if base.held_piece.is_empty():
		return
	for i: Vector2i in base.held_piece[0]:
		set_cell_item(convert_vec2_vec3(i) + offset, base.held_piece_color if base.can_hold else 8)
