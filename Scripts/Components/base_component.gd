@icon("res://Assets/Editor/component.png")

class_name BaseComponent
extends Node

@export var active_piece: ActivePiece

var parent: BaseGame:
	get:
		return get_parent()
