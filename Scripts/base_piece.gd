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
			move_side("left")
			
		if Input.is_action_just_pressed("right"):
			move_side("right")

func move_down(spaces := 1):
	var can_move_down = true
	for block in get_children():
		#print(block.get_collision_point())
		if !block.get_collision_point():
			grounded = true
			spawn_new_piece()
			set_physics_process(false)
			disable_all_blocks()
			can_move_down = false
			return
	if can_move_down:
		position.y -= 2 * spaces
			
#func move_left():
	#var can_move_left = true
	#for block in get_children():
		#print(block.get_collision_point())
		#block.left()
		#if block.get_collision_side_point() < -8:
			#can_move_left = false
	#if can_move_left:
		#position.x -= 2
			#
#func move_right():
	#var can_move_right = true
	#for block in get_children():
		#print(block.get_collision_point())
		#block.right()
		#if block.get_collision_side_point() > 8:
			#can_move_right = false
	#if can_move_right:
		#position.x += 2

func spawn_new_piece():
	get_parent().spawn_random_piece()
	
func disable_all_blocks():
	for block in get_children():
		block.inactive()

func move_side(dir : String):
	var can_move_left = false
	var can_move_right = false
	for block in get_children():
		#print(block.get_collision_point())
		match dir:
			"left":
				if !block.left():
					can_move_left = false
				else:
					can_move_left = true
			"right":
				if !block.right():
					can_move_right = false
				else:
					can_move_right = true
	if can_move_left:
		position.x -= 2
	if can_move_right:
		position.x += 2
