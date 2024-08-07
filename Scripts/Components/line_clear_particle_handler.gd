class_name ParticleHandler
extends BaseComponent

@export var particles: PackedScene
@export var board : GameBoard3D
@export var offset: Vector3

@onready var temp_grid: GridMap = $GridMap


func _ready() -> void:
	parent.lines_cleared.connect(_on_lines_cleared)

func j(i: int) -> int:
	i *= -2
	i += 24
	return i

func _on_lines_cleared(lines: Array[int]) -> void:

	#print(lines)
	#for i in 20:
		#print("i: ", i, ", j: ", j(i))


	#var t := board.map_to_local(Vector3i(0, j(lines.max()), 0))
	#print(t)
	#temp_grid.set_cell_item(t, 1)

	var new_particles := particles.instantiate()
	new_particles.position.y = j(lines.max())

	#new_particles.position.y *= 1.5
	new_particles.finished.connect(
			func() -> void:
				Engine.time_scale = 1
				new_particles.queue_free())
	add_child(new_particles)
	new_particles.restart()
	Engine.time_scale = 0.2

