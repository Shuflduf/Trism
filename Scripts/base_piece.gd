class_name BasePiece
extends Node3D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	if Engine.get_physics_frames() % 20 == 0:
		move_down()
		
	if Input.is_action_just_pressed("soft"):
		move_down()
	
	if Input.is_action_just_pressed("left"):
		move_left()
		
	if Input.is_action_just_pressed("right"):
		move_right()

func move_down(spaces := 1):
	for child in get_children():
		if child.check_coll():
			return
		
	position.y -= spaces * 2
		

func move_left():
	pass #TODO
			
func move_right():
	pass #TODO
