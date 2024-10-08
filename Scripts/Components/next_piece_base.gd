class_name HoldPiece
extends BaseComponent

signal update

var held_piece := []
var held_piece_color: int

var can_hold := true
var just_held := false

func _ready() -> void:
	active_piece.piece_placed.connect(func() -> void:
		if !just_held:
			can_hold = true
			update.emit()
		else:
			just_held = false
		)

	parent.game_start.connect(func() -> void:
		held_piece = []
		can_hold = true
		just_held = false
		update.emit())

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("hold"):
		hold_piece()

func hold_piece() -> void:
	if parent.lost or parent.paused:
		return

	if can_hold:
		held_piece_color = active_piece.piece_color

		if held_piece.is_empty():
			held_piece = active_piece.piece_type
			active_piece.piece_moved.emit()

			just_held = true
			active_piece.piece_type = []
			active_piece.create_piece()
		else:
			var temp_piece := active_piece.piece_type
			active_piece.piece_type = held_piece
			held_piece = temp_piece

			active_piece.current_loc = active_piece.SPAWN
			active_piece.rotation_index = 0

			active_piece.piece_color = active_piece.active_table.shapes\
					.find(active_piece.piece_type)

			active_piece.piece_moved.emit()

		can_hold = false
		update.emit()



