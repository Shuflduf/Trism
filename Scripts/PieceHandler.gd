extends Node3D

@export var piece : Array[PackedScene]
@onready var spawn_pos = %SpawnPos


# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_random_piece()

func spawn_random_piece():
	var new_piece = piece.pick_random().instantiate()
	new_piece.global_position = spawn_pos.global_position
	add_child(new_piece)
