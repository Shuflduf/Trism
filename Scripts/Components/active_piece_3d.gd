class_name ActivePiece3D
extends BaseComponent3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	active_piece.piece_moved.connect(draw)


func draw() -> void:
	clear()
	for i: Vector2i in active_piece.piece_type[active_piece.rotation_index]:
		var loc := convert_vec2_vec3(i + active_piece.current_loc)
		loc += offset
		set_cell_item(loc, active_piece.piece_color)

