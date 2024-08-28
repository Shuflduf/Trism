@icon("res://Assets/Editor/component3d.png")
class_name BaseComponent3D
extends GridMap

@export var offset: Vector3i
#@export var active_piece: ActivePiece

#var parent: BaseGame:
	#get:
		#return get_parent()

#helper function that converts 2d values to 3d
func convert_vec2_vec3(vec2 : Vector2i) -> Vector3i:
	return Vector3i(vec2.x, -vec2.y, 0)
