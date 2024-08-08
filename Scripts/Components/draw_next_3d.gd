class_name NextPieces3D
extends BaseComponent3D

@export var bag: BagHandler

var next_pieces_tween : Tween





func _ready() -> void:
	bag.set_piece.connect(func() -> void:
		draw(bag.next, active_piece.active_table))

	parent.game_start.connect(func() -> void:
		draw(bag.next, active_piece.active_table))


func draw(pieces: Array, table: KickTable) -> void:

	var vertical_offset := pieces.size() * 4
	clear()

	if next_pieces_tween:
		next_pieces_tween.kill()
		position.y = 4
	next_pieces_tween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	next_pieces_tween.tween_property(self, "position:y", 4, 1)

	position.y = 0

	for piece: Array in pieces:
		for pos: Vector2i in piece[0]:

			var cell_position := convert_vec2_vec3(pos) + \
					Vector3i(0, ((bag.next_piece_count * 4) + 5) - vertical_offset, 0)
			cell_position += offset

			set_cell_item(cell_position, table.shapes.find(piece))
		vertical_offset += 4
