class_name BaseCube
extends MeshInstance3D

@onready var area_3d = $Area3D


func _on_area_3d_area_entered(_area):
	pass

func check_coll():
	if area_3d.get_overlapping_areas() != []:
		return false
