class_name Tetris
extends GridMap

@onready var gameover = $"../UI/Gameover"
@onready var animation_player = %AnimationPlayer
@onready var pause_menu = %PauseMenu

#grid consts
const ROWS := 20
const COLS := 10
const SPAWN = Vector3i(-1, 13, 0)
const TRANSPARENT_PIECES = [-1, 8]

#game state vars
var lost = false
var paused = false
var can_hold = true

#game piece vars
var piece_type
var next_pieces : Array
var next_piece_color
var rotation_index : int = 0
var active_piece : Array
var current_loc
var ghost_positions : Array

var held_piece := []
var held_piece_color
var current_held_piece : Array

#grid vars
var cube_id : int = 0
var piece_color : int
var current_shown_pieces = []
var next_piece_count := 5

#movement variables
const directions := [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.DOWN]
var steps : Array
const steps_req : int = 50
var speed : float
const ACCEL : float = 0.01

var bag = SRS.shapes.duplicate()

#helper function that converts 2d values to 3d
func convert_vec2_vec3(vec2 : Vector2i) -> Vector3i:
	return Vector3i(vec2.x, -vec2.y, 0)

#handles initial game run
func _ready():
	animation_player.assigned_animation = "countdown"
	lost = true
	randomize()
	await SceneManager.transitioned_out
	new_game()
	
#handles what happens every frame TODO: make it work with any framerate
func _process(_delta):
	if Input.is_action_just_pressed("pause"):
			pause_game()
	if !lost and !paused:
		if Input.is_action_pressed("left"):
			steps[0] += 10
		if Input.is_action_pressed("right"):
			steps[1] += 10
		if Input.is_action_pressed("soft"):
			steps[2] += 10
		if Input.is_action_just_pressed("hard"):
			hard_drop()
		if Input.is_action_just_pressed("hold"):
			hold_piece()
		if Input.is_action_just_pressed("rot_left"):
			rotate_piece("left")
		if Input.is_action_just_pressed("rot_right"):
			rotate_piece("right")
			
		
		steps[2] += speed
		for i in range(steps.size()):
			if steps[i] > steps_req:
				move_piece(directions[i])
				steps[i] = 0
	
#handles everything when starting a new game
func new_game():
	clear_board()
	draw_top()
	shuffle_bag()
	show_next_pieces(next_pieces)
	speed = 1.0
	steps = [0, 0, 0]
	gameover.hide()
	animation_player.play("countdown")
	await animation_player.animation_finished
	lost = false
	clear_held_piece()
	held_piece = []
	create_piece()
	
#handles the bag and chooses a piece from it
func pick_piece():
	var piece
	if not bag.is_empty():
		bag.shuffle()
		piece = bag.pop_front()
	else:
		bag = SRS.shapes.duplicate()
		bag.shuffle()
		piece = bag.pop_front()
	return piece

#shuffles the bag
func shuffle_bag():
	bag = SRS.shapes.duplicate()
	next_pieces = []
	for i in next_piece_count:
		next_pieces.append(pick_piece())

#handles next pieces
func next_piece():
	next_pieces.pop_front()
	next_pieces.append(pick_piece())
	show_next_pieces(next_pieces)

#clears and draws the next piece
func show_next_pieces(pieces: Array):
	for cell in current_shown_pieces:
		set_cell_item(cell, -1)
	var vertical_offset = 0
	for piece in pieces:
		for pos in piece[0]:
			var cell_position = convert_vec2_vec3(pos) + Vector3i(8, 8 - vertical_offset, 0)
			current_shown_pieces.append(cell_position)
			set_cell_item(cell_position, SRS.shapes.find(piece))
		vertical_offset += 4

#handles new piece creation
func create_piece():
	check_rows()
	steps = [0, 0, 0]
	current_loc = SPAWN
	rotation_index = 0
	detect_lost()
	
	if !lost:
		can_hold = true
		
		piece_type = next_pieces[0]
		piece_color = SRS.shapes.find(piece_type)
		next_piece()
	
		active_piece = piece_type[rotation_index]
		draw_piece(active_piece, SPAWN)
		show_held_piece(held_piece, held_piece_color)
		draw_top()

#clears the drawn piece to avoid ghosting
func clear_piece():
	for i in active_piece:
		set_cell_item(convert_vec2_vec3(i) + current_loc, -1)

#draws the piece
func draw_piece(piece, pos):
	draw_top()
	handle_ghost()
	for i in piece:
		set_cell_item(convert_vec2_vec3(i) + pos, piece_color)
	
#rotates the piece
func rotate_piece(dir):
	if can_rotate(dir):
		clear_piece() 
		match dir:
			"left":
				rotation_index = (rotation_index - 1) % 4
			"right":
				rotation_index = (rotation_index + 1) % 4
		active_piece = piece_type[rotation_index]

		draw_piece(active_piece, current_loc)
	
#checks if the piece can perform a valid rotation
func can_rotate(dir):
	var cr = true
	var temp_rotation_index
	match dir:
		"left":
			temp_rotation_index = (rotation_index - 1) % 4
		"right":
			temp_rotation_index = (rotation_index + 1) % 4
	for i in piece_type[temp_rotation_index]:
		var next_pos = convert_vec2_vec3(i) + current_loc
		if not is_free(next_pos, true):
			cr = false
			break
	return cr

#moves the piece in a specified direction
func move_piece(dir):
	
	if can_move(dir):
		clear_piece()
		current_loc += convert_vec2_vec3(dir)
		draw_piece(active_piece, current_loc)
		
	elif dir == Vector2i.DOWN:
		create_piece()

#checks if the piece can move in a specified direction
func can_move(dir):
	var cm = true
	for square in active_piece:
		var next_pos = convert_vec2_vec3(square) + current_loc + convert_vec2_vec3(dir)
		if not is_free(next_pos, true):
			cm = false
			break
	return cm
	
#helper function that checks if a current grid space is free
func is_free(pos : Vector3i, exclude_active_piece: bool = false) -> bool:
	if exclude_active_piece:
		for block_pos in active_piece:
			if convert_vec2_vec3(block_pos) + current_loc == pos:
				return true
	for i in TRANSPARENT_PIECES:
		if get_cell_item(pos) == i:
			return true
	return false

#hard drops the piece
func hard_drop():

	while can_move(directions[2]):
		move_piece(directions[2])
	create_piece()

#all the ghost piece functions bundled together since i didnt feel like writing them everywhere
func handle_ghost():
	clear_ghost()
	var dist = find_ghost_positions()
	draw_ghost(dist)

#finds how far the ghost piece has to move down
func find_ghost_positions() -> int:
	ghost_positions = []
	var min_drop_distance = 9999

	for i in active_piece:
		var drop_distance = 0
		var ghost_pos = convert_vec2_vec3(i) + current_loc

		while is_free(ghost_pos + Vector3i(0, -1, 0), true):
			ghost_pos += Vector3i(0, -1, 0)
			drop_distance += 1

		if drop_distance < min_drop_distance:
			min_drop_distance = drop_distance

	return min_drop_distance

#draws the ghost piece
func draw_ghost(dist : int):
	for i in active_piece:
		var ghost_pos = convert_vec2_vec3(i) + current_loc + Vector3i(0, -dist, 0)
		ghost_positions.append(ghost_pos)
		set_cell_item(ghost_pos, 8) 

#clears the current ghost piece before drawing a new one, to avoid "ghosting"
func clear_ghost():
	for i in ghost_positions:
		if get_cell_item(i) == 8:
			set_cell_item(i, -1)
	ghost_positions = []

#handles everything related to holding pieces
func hold_piece():
	if can_hold:
		held_piece_color = piece_color
		clear_held_piece()
		if held_piece == []:
			held_piece = piece_type
			clear_piece()
			create_piece()
		else:
			clear_piece()
			
			var temp_piece = piece_type
			piece_type = held_piece
			held_piece = temp_piece
			current_loc = SPAWN
			rotation_index = 0
			
			active_piece = piece_type[rotation_index]
			piece_color = SRS.shapes.find(piece_type)
			
			draw_piece(active_piece, current_loc)

		show_held_piece(held_piece, 8)
		can_hold = false
	#else:
		#show_held_piece(held_piece, 8)
	
#shows the active held piece
func show_held_piece(piece : Array, color):
	if piece != []:
		for i in piece[0]:
			var piece_pos = convert_vec2_vec3(i + Vector2i(-11, -8))
			set_cell_item(piece_pos, color)
			current_held_piece.append(piece_pos)
	
#clear held piece
func clear_held_piece():
	for i in current_held_piece:
		set_cell_item(i, -1)
		
#draws that little transparent bar at the top
func draw_top():
	
	for i in COLS:
		if is_free(Vector3i(i -5, 10, 0)):
			set_cell_item(Vector3i(i -5, 10, 0), 8)

#checks if any rows are full
func check_rows():

	var rows_to_clear = []
	
	for row in range(-ROWS, 10):
		var is_row_full = true
		
		@warning_ignore("integer_division", "integer_division")
		for col in range(-COLS/2, COLS/2):
			if is_free(Vector3i(col, row, 0)):
				is_row_full = false
				break
		
		if is_row_full and row != -11:
			rows_to_clear.append(row)
	
	if rows_to_clear.size() > 0:
		move_down_rows(rows_to_clear)

#clears rows and moves pieces above it down
func move_down_rows(cleared_rows_indices: Array) -> void:
	cleared_rows_indices.sort()

	# Clear the rows
	for row in cleared_rows_indices:
		@warning_ignore("integer_division", "integer_division", "integer_division")
		for col in range(-COLS/2, COLS/2):
			set_cell_item(Vector3i(col, row, 0), -1)

	# Move pieces down
	for row in range(cleared_rows_indices[0] + 1, 11):
		var rows_to_move_down = 0
		for cleared_row in cleared_rows_indices:
			if row > cleared_row:
				rows_to_move_down += 1
			else:
				break

		if rows_to_move_down > 0:
			@warning_ignore("integer_division")
			for col in range(-COLS/2, COLS/2):
				var item_col = get_cell_item(Vector3i(col, row, 0))
				if !is_free(Vector3i(col, row, 0)):
					set_cell_item(Vector3i(col, row - rows_to_move_down, 0), item_col)
					set_cell_item(Vector3i(col, row, 0), -1)
		speed += ACCEL

#how did i get 3d buttons to work
func _on_button_input_event(_camera, event, _position, _normal, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed == true:
			new_game()

#clears the board
func clear_board():
	for y in range(-10, 20):
		@warning_ignore("integer_division", "integer_division")
		for x in range(-COLS/2, COLS/2):
			set_cell_item(Vector3i(x, y, 0), -1)

#detects if you lost the game
func detect_lost():
	@warning_ignore("integer_division")
	for x in range(-COLS/2 , COLS/2 ):
		if !is_free(Vector3i(x, 11, 0), true):
			game_lost()
			
#handles losing
func game_lost():
	gameover.visible = true
	lost = true

#i dont know what this does
func pause_game():
	if paused:
		#code to unpause
		if animation_player.is_playing():
			animation_player.speed_scale = 1
		paused = false
		pause_menu.visible = false
	else:
		#code to pause
		if animation_player.is_playing():
			animation_player.speed_scale = 0
		paused = true
		pause_menu.visible = true
