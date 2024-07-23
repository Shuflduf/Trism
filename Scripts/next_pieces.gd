class_name NextPieces
extends Node

@export var next_piece_count := 5

var next : Array

var bag 
@onready var active_table = get_parent().active_table

func next_piece():
	next.pop_front()
	next.append(pick_piece())

func pick_piece():
	var piece
	if not bag.is_empty():
		bag.shuffle()
		piece = bag.pop_front()
	else:
		bag = active_table.shapes.duplicate()
		bag.shuffle()
		piece = bag.pop_front()
	return piece

#shuffles the bag
func shuffle_bag():
	bag = active_table.shapes.duplicate()
	next = []
	for i in next_piece_count:
		next.append(pick_piece())

func _ready() -> void:
	get_parent().piece_placed.connect(func():
		next_piece())
