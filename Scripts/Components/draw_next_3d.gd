class_name NextPieces3D
extends BaseComponent3D

#@export var active
@onready var board: BaseGame = $"../.."

var next_pieces_tween : Tween





func _ready() -> void:
	get_parent().set_piece.connect(func() -> void:
		draw(get_parent().next, get_parent().active_piece.active_table))

	board.game_start.connect(func() -> void:
		draw(get_parent().next, get_parent().active_piece.active_table))


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
					Vector3i(0, ((get_parent().next_piece_count * 4) + 5) - vertical_offset, 0)
			cell_position += offset

			set_cell_item(cell_position, table.shapes.find(piece))
		vertical_offset += 4
