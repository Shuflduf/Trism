class_name BasePiece
extends Node3D

var bounds = {
	"left" : -7,
	"right" : 6,
	"down" : -21,
}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	if Engine.get_physics_frames() % 30 == 0:
		move_down()
		
	if Input.is_action_just_pressed("soft"):
		move_down()
	
	if Input.is_action_just_pressed("left"):
		move_side("left")

func move_down(spaces := 1):
	if !position.y - (spaces * 2) < -21:
		position.y -= spaces * 2

func move_side(direction : String):
	match direction:
		"left" : position.x -= 2
	if direction == "left" and detect_out_bounds("left"):
		position.x -= 2
		
func detect_out_bounds(direction):
	for child in get_parent().get_children():
		if position.x < bounds[direction]:
			print("AHGGF")
			return false
		else:
			return true
