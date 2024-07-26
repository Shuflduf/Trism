@icon("res://Assets/Editor/component.png")

class_name HoldPiece
extends BaseComponent

var held_piece := []
var held_piece_color: int
var current_held_piece : Array

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("hold"):
		hold_piece()

func hold_piece() -> void:
	pass
