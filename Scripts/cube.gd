class_name BaseCube
extends MeshInstance3D

@onready var downray = $DownRay
@onready var area3d = $Area3D
@onready var sideray = $SideRay as RayCast3D

#func _physics_process(delta):
	#print(sideray.get_collision_point().x - global_position.x)

func get_collision_point():
	return global_position.y - downray.get_collision_point().y > 2

func inactive():
	downray.enabled = false
	area3d.set_collision_layer_value(3, false)
	area3d.set_collision_layer_value(2, true)

func left():
	sideray.target_position.x = -50
	return (global_position.x - sideray.get_collision_point().x)
	
func right():
	sideray.target_position.x = 50
	return (global_position.x - sideray.get_collision_point().x)

