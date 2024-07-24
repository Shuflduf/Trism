@icon("res://Assets/Editor/component3d.png")

class_name NextPieces3DDrawer
extends GridMap

@export var bag: BagHandler

var next_pieces_tween : Tween


#helper function that converts 2d values to 3d
func convert_vec2_vec3(vec2 : Vector2i) -> Vector3i:
	return Vector3i(vec2.x, -vec2.y, 0)


func _ready() -> void:
	bag.set_piece.connect(func() -> void:
		draw(bag.next, get_parent().active_table))

	get_parent().game_start.connect(func() -> void:
		draw(bag.next, get_parent().active_table))


func draw(pieces: Array, table: KickTable) -> void:
	var vertical_offset := 0
	for piece: Array in pieces:
		for pos: Vector2i in piece[0]:
			var cell_position := convert_vec2_vec3(pos) + Vector3i(8, 6 - vertical_offset, 0)
			set_cell_item(cell_position, table.shapes.find(piece))
		vertical_offset += 4

	clear()

	if next_pieces_tween:
		next_pieces_tween.kill()
		position.y = 4
	next_pieces_tween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	next_pieces_tween.tween_property(self, "position:y", 4, 1)

	position.y = 0

	for piece: Array in pieces:
		for pos: Vector2i in piece[0]:
			var cell_position := convert_vec2_vec3(pos) + Vector3i(8, 26 - vertical_offset, 0)
			set_cell_item(cell_position, table.shapes.find(piece))
		vertical_offset += 4
