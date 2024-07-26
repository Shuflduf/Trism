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
	get_parent().piece_moved.connect(func() -> void:
		ghost())

func ghost() -> void:
	#ghost_positions = []
	var min_drop_distance := 99

	for i: Vector2i in parent.active_piece:
		var drop_distance := 1
		var ghost_pos := i + parent.current_loc + Vector2i(0, 1)

		while parent.is_free(ghost_pos + Vector2i(0, -1), true):
			ghost_pos += Vector2i(0, 1)
			drop_distance += 1

		if drop_distance < min_drop_distance:
			min_drop_distance = drop_distance

	print(min_drop_distance)
	draw_ghost(min_drop_distance)

func draw_ghost(dist: int) -> void:
	clear()

	var current_piece_locs: Array[Vector2i] = []

	for i: Vector2i in parent.active_piece:
		current_piece_locs.append(i + parent.current_loc)

	for i: Vector2i in current_piece_locs:
		var ghost_pos := i + Vector2i(0, dist - 2)

		if ghost_pos in current_piece_locs:
			continue

		set_cell_item(convert_vec2_vec3(ghost_pos) + offset, 8)
