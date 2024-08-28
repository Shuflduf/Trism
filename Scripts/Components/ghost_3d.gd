class_name GhostPiece3D
extends BaseComponent3D

@onready var board: BaseGame = $"../.."


func _ready() -> void:
	get_parent().piece_moved.connect(func() -> void:
		ghost())

func ghost() -> void:
	#ghost_positions = []
	var min_drop_distance := 99

	if get_parent().piece_type == []:
		return

	for i: Vector2i in get_parent().piece_type[get_parent().rotation_index]:
		var drop_distance := 1
		var ghost_pos: Vector2i = i + get_parent().current_loc + Vector2i(0, 1)

		while board.is_free(ghost_pos + Vector2i(0, -1)):
			ghost_pos += Vector2i(0, 1)
			drop_distance += 1

		if drop_distance < min_drop_distance:
			min_drop_distance = drop_distance

	draw_ghost(min_drop_distance)

func draw_ghost(dist: int) -> void:
	clear()

	var current_piece_locs: Array[Vector2i] = []

	for i: Vector2i in get_parent().piece_type[get_parent().rotation_index]:
		current_piece_locs.append(i + get_parent().current_loc)

	for i: Vector2i in current_piece_locs:
		var ghost_pos := i + Vector2i(0, dist - 2)

		if ghost_pos in current_piece_locs:
			continue

		set_cell_item(convert_vec2_vec3(ghost_pos) + offset, 8)
