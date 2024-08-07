@icon("res://Assets/Editor/component3d.png")
class_name BaseComponent3D
extends GridMap

@export var active_piece: ActivePiece

var parent: BaseGame:
	get:
		return get_parent()
