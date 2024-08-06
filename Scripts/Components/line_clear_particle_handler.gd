class_name ParticleHandler
extends BaseComponent

@export var particles: PackedScene

func _ready() -> void:
	parent.lines_cleared.connect(_on_lines_cleared)

func _on_lines_cleared(lines: Array[int]) -> void:
	var new_particles := particles.instantiate()
	new_particles.position.y = -lines.max()
	add_child(new_particles)

