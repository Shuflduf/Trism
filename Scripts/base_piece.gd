class_name BasePiece
extends Node3D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	if Engine.get_physics_frames() % 30 == 0:
		move_down()
		
	if Input.is_action_just_pressed("soft"):
		move_down()
	
	if Input.is_action_just_pressed("left"):
		move_left()
		
	if Input.is_action_just_pressed("right"):
		move_right()

func move_down(spaces := 1):
	if !get_child(0).get_child(0):
		position.y -= spaces * 2
	else:
		print(get_tree().root.get_child(0).spawn_random_piece())
		
func detect_out_bounds(direction):
	for child in get_parent().get_children():
		if position.x < bounds[direction]:
			print("AHGGF")
			return false
		else:
			return false

func move_left():
	# Check if any child would go out of bounds with the proposed move
	for child in get_children():
		if child.global_position.x - 2 < bounds.left:
			print(child.position.x)
			return  # If any child would go out of bounds, don't move any of them

	# If none would go out of bounds, proceed with the move
	position.x -= 2
			
func move_right():
	# Check if any child would go out of bounds with the proposed move
	for child in get_children():
		if child.global_position.x + 2 > bounds.right:
			print(child.position.x)
			return  # If any child would go out of bounds, don't move any of them

	# If none would go out of bounds, proceed with the move
	position.x += 2			
