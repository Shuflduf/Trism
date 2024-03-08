class_name BaseCube
extends MeshInstance3D

@onready var raycast = $RayCast3D
@onready var area3d = $Area3D


func _physics_process(_delta):
	print(global_position.y - raycast.get_collision_point().y)

func get_collision_point():
	return global_position.y - raycast.get_collision_point().y

func inactive():
	raycast.enabled = false
	area3d.set_collision_layer_value(3, false)
	area3d.set_collision_layer_value(2, true)
