class_name HoldPiece3D
extends BaseComponent3D

@export var base: HoldPiece


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
