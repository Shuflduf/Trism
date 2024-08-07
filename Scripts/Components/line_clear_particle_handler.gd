class_name ParticleHandler
extends BaseComponent

@export var particles: PackedScene
@export var mesh_library: MeshLibrary
@export var offset: Vector3

func _ready() -> void:
	parent.lines_cleared.connect(_on_lines_cleared)


func _on_lines_cleared(lines: Array[int], colour: int) -> void:
	print(colour)
	var new_particles := particles.instantiate()
	new_particles.position.y = lines.max() * -2
	new_particles.position += offset
	new_particles.draw_pass_1.material.albedo_color = get_colour(colour)
	new_particles.finished.connect(
			func() -> void:
				new_particles.queue_free())
	add_child(new_particles)
	new_particles.restart()

func get_colour(index: int) -> Color:
	var colour: Color = mesh_library.get_item_mesh(index).surface_get_material(0).albedo_color
	return colour



