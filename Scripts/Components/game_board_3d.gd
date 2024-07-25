@icon("res://Assets/Editor/component3d.png")

class_name GameBoard3D
extends GridMap

@export var offset: Vector3i

#helper function that converts 2d values to 3d
func convert_vec2_vec3(vec2 : Vector2i) -> Vector3i:
	return Vector3i(vec2.x, -vec2.y, 0)

func _ready() -> void:
	get_parent().update_board.connect(func() -> void:
		draw())

func draw() -> void:
	for row: int in get_parent().game.size():
		for col: int in get_parent().game[0].size():
			set_cell_item(Vector3i(col, -row, 0) + offset, get_parent().game[row][col])
