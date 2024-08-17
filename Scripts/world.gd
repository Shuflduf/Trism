extends Node3D

@onready var env: Environment = %WorldEnvironment.environment

func _process(delta: float) -> void:
	env.sky_rotation.y += deg_to_rad(delta * 1.5)
