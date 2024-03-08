class_name BasePiece
extends Node3D

signal touching_ground
var grounded = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	if !grounded:
		if Engine.get_physics_frames() % 20 == 0:
			move_down()
		
	if Input.is_action_just_pressed("soft"):
		move_down()
	
	if Input.is_action_just_pressed("left"):
		move_left()
		
	if Input.is_action_just_pressed("right"):
		move_right()

func check_if_grounded():
	for block in get_children():
		print(block.get_collision_point())
		if block.get_collision_point() < 2:
			block.inactive()
			grounded = true
			

func move_down(spaces := 1):
	#for child in get_children():
		#if child.check_coll():
			#return
		
	position.y -= spaces * 2
		

func move_left():
	pass #TODO
			
func move_right():
	pass #TODO
