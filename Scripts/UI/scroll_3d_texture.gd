@tool
extends CSGBox3D

func _ready() -> void:
	material.uv1_offset.x = 0.0


func _process(delta: float) -> void:
	material.uv1_offset.x += delta / 10
