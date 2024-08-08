class_name BagHandler
extends BaseComponent

signal set_piece

@export_range(1, 6, 1) var next_piece_count := 5

var next: Array
var bag: Array

func next_piece() -> Array:
	var n: Array = next.pop_front()
	next.append(pick_piece())
	return n

func pick_piece() -> Array:
	return []

func shuffle_bag() -> void:
	bag.clear()
	next.clear()
	for i in next_piece_count:
		next.append(pick_piece())

func _ready() -> void:
	active_piece.piece_placed.connect(func() -> void:
		active_piece.piece_type = next_piece()
		set_piece.emit())

	parent.game_start.connect(func() -> void:
		shuffle_bag()
		set_piece.emit())
