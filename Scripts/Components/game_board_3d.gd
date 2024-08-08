class_name GameBoard3D
extends BaseComponent3D



func _ready() -> void:
	get_parent().update_board.connect(func() -> void:
		draw())

func draw() -> void:
	for row: int in get_parent().game.size():
		for col: int in get_parent().game[0].size():
			set_cell_item(Vector3i(col, -row, 0) + offset, get_parent().game[row][col])
