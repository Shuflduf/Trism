@icon("res://Assets/Editor/component3d.png")

class_name GhostPiece3D
extends GridMap

@export var game_board: GameBoard3D

var parent: BaseGame:
	get:
		return get_parent()

var offset: Vector3i

func convert_vec2_vec3(vec2 : Vector2i) -> Vector3i:
	return Vector3i(vec2.x, -vec2.y, 0)

func _ready() -> void:
	if game_board:
		offset = game_board.offset
	get_parent().update_board.connect(func() -> void:
		draw_ghost(ghost()))

func ghost() -> int:
	#ghost_positions = []
	var min_drop_distance := 9999

	for i: Vector2i in parent.active_piece:
		var drop_distance := 0
		var ghost_pos := i + parent.current_loc

		while parent.is_free(ghost_pos + Vector2i(0, -1), true):
			ghost_pos += Vector2i(0, -1)
			drop_distance += 1

		if drop_distance < min_drop_distance:
			min_drop_distance = drop_distance

	return min_drop_distance

func draw_ghost(dist: int) -> void:
	clear()
	for i: Vector2i in parent.active_piece:
		var ghost_pos := i + parent.current_loc + Vector2i(0, -dist)
		#ghost_pos *= Vector2i(1, -1)
		#ghost_positions.append(ghost_pos)
		set_cell_item(convert_vec2_vec3(ghost_pos) + offset, 8)
