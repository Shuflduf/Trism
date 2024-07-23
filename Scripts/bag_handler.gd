class_name BagHandler
extends Node

@export var next_piece_count := 5

var next: Array
var bag: Array

func next_piece():
	next.pop_front()
	next.append(pick_piece())
	return next[0]
	
func pick_piece():
	pass

func _ready() -> void:
	get_parent().piece_placed.connect(func():
		get_parent().piece_type = next_piece())
