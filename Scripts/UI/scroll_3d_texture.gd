extends CSGBox3D



func _process(delta: float) -> void:
	material.uv1_offset.x += delta / 10
