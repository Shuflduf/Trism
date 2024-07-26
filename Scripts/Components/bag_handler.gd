class_name BagHandler
extends BaseComponent

signal set_piece

@export_range(1, 6, 1) var next_piece_count := 5

var next: Array
var bag: Array

func next_piece() -> Array:
	var n: Array = next.pop_front()
	next.append(pick_piece())
	set_piece.emit()
	return n

func pick_piece() -> Array:
	return []

func shuffle_bag() -> void:
	return

func _ready() -> void:
	get_parent().piece_placed.connect(func() -> void:
		get_parent().piece_type = next_piece())

	get_parent().game_start.connect(func() -> void:
		shuffle_bag())
