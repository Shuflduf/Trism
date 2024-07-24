@icon("res://Assets/Editor/component3d.png")

class_name GameBoard3D
extends GridMap

#helper function that converts 2d values to 3d
func convert_vec2_vec3(vec2 : Vector2i) -> Vector3i:
	return Vector3i(vec2.x, -vec2.y, 0)
