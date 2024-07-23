class_name BagHandler
extends Node

signal set_piece

@export var next_piece_count := 5

var next: Array
var bag: Array

func next_piece():
	var n = next.pop_front()
	next.append(pick_piece())
	set_piece.emit()
	return n
	
func pick_piece():
	pass

func shuffle_bag():
	pass

func _ready() -> void:
	get_parent().piece_placed.connect(func():
		get_parent().piece_type = next_piece())
		
	get_parent().game_start.connect(func():
		shuffle_bag())
