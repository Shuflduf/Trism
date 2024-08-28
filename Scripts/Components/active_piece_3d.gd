class_name ActivePiece3D
extends BaseComponent3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_parent().piece_moved.connect(draw)


func draw() -> void:
	clear()

	if get_parent().piece_type == []:
		return

	for i: Vector2i in get_parent().piece_type[get_parent().rotation_index]:
		var loc := convert_vec2_vec3(i + get_parent().current_loc)
		loc += offset
		set_cell_item(loc, get_parent().piece_color)
