extends GridMap

@export var active_table : SRS

@onready var gameover = $"../UI/Gameover"
@onready var animation_player = %AnimationPlayer
@onready var pause_menu = %PauseMenu
@onready var next_pieces_grid = $NextPieces
@onready var env = %WorldEnvironment.environment
@onready var cleared = %Cleared

var cleared_lines = {
	1 : "One",
	2 : "Two",
	3 : "Three",
	4 : "Four",
}

var grid_3x3_corners = [Vector2i(0, 0), Vector2i(0, 2), Vector2i(2, 0), Vector2i(2, 2)]

# Handling stuff
var DAS := 10  # Delay in frames before auto-repeat starts
var ARR := 2  # Time in frames between auto-repeats
var SDF := 6.0 # Soft Drop Factor

# Timers for each direction
var left_timer := 0
var right_timer := 0
var down_timer := 0

var moving_left = false
var moving_right = false
var soft_dropping = false

#grid consts
const ROWS := 20
const COLS := 10
const SPAWN = Vector3i(-2, 13, 0)
const TRANSPARENT_PIECES = [-1, 8]

#game state vars
var lost = false
var paused = false
var can_hold = true

#game piece vars
var counting = false
var drop_timer := 0
var temp_timer := 0
const MAX_DROP_TIME = 120
const TEMP_DROP_TIME = 40

var tspin_valid

var piece_type
var next_pieces_tween : Tween
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
var steps_req = 50

# ways gravity could work
# 1. how much it moves down each frame
# 2. a counter that counts up each frame, and moves down when above a threshold
# 3. yea 2 works
var grav_counter : int
const STARTER_GRAV = 30.0
var active_gravity : float = STARTER_GRAV
const ACCEL := 0.01

var bag 

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
	
#handles what happens every frame
func _physics_process(_delta):
	if Input.is_action_just_pressed("pause"):
		pause_menu.handle_pause()

	if !lost and !paused:
		
		if Input.is_action_just_pressed("left"):
			move_piece(directions[0])
			moving_left = true
			moving_right = false
			
		if Input.is_action_just_pressed("right"):
			move_piece(directions[1])
			moving_left = false
			moving_right = true
		
		if Input.is_action_just_released("left"):
			if Input.is_action_pressed("right"):
				move_piece(directions[1])
				moving_right = true
			moving_left = false
		
		if Input.is_action_just_released("right"):
			if Input.is_action_pressed("left"):
				move_piece(directions[0])
				moving_left = true
			moving_right = false
		
		# Handle DAS for left movement
		if moving_left:
			left_timer += 1
			if left_timer > DAS:
				if left_timer % ARR == 0:
					move_piece(directions[0])
		else:
			left_timer = 0

		# Handle DAS for right movement
		if moving_right:
			right_timer += 1
			if right_timer > DAS:
				if right_timer % ARR == 0:
					move_piece(directions[1])
		else:
			right_timer = 0
		

		if Input.is_action_just_pressed("soft"):
			soft_dropping = true
			change_gravity(active_gravity / SDF)
			
		if Input.is_action_just_released("soft"):
			soft_dropping = false
			change_gravity(active_gravity * SDF)
			
			
		grav_counter += 1
		if grav_counter > active_gravity:
			move_piece(directions[2])
			grav_counter = 0
			
		if counting:
			drop_timer += 1
			temp_timer += 1
			if temp_timer > TEMP_DROP_TIME or drop_timer > MAX_DROP_TIME:
				drop_timer = 0
				temp_timer = 0
				hard_drop()


		
		
		# Other controls
		if Input.is_action_just_pressed("hard"):
			hard_drop()
		if Input.is_action_just_pressed("hold"):
			hold_piece()
		if Input.is_action_just_pressed("rot_left"):
			rotate_piece("left")
		if Input.is_action_just_pressed("rot_right"):
			rotate_piece("right")

#handles everything when starting a new game
func new_game():
	clear_held_piece()
	clear_board()
	draw_top()
	shuffle_bag()
	show_next_pieces(next_pieces)
	change_gravity(STARTER_GRAV)
	gameover.hide()
	animation_player.play("countdown")
	await animation_player.animation_finished
	lost = false
	
	held_piece = []
	create_piece()
	
#handles the bag and chooses a piece from it
func pick_piece():
	var piece
	if not bag.is_empty():
		bag.shuffle()
		piece = bag.pop_front()
	else:
		bag = active_table.shapes.duplicate()
		bag.shuffle()
		piece = bag.pop_front()
	return piece

#shuffles the bag
func shuffle_bag():
	bag = active_table.shapes.duplicate()
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
	var vertical_offset = 0
	for piece in pieces:
		for pos in piece[0]:
			var cell_position = convert_vec2_vec3(pos) + Vector3i(8, 6 - vertical_offset, 0)
			current_shown_pieces.append(cell_position)
			next_pieces_grid.set_cell_item(cell_position, active_table.shapes.find(piece))
		vertical_offset += 4
		
	for i in range(0,3):
		for cell in current_shown_pieces[i]:
			next_pieces_grid.set_cell_item(cell, -1)
			
	if next_pieces_tween:
		next_pieces_tween.kill()
		next_pieces_grid.position.y = 4
	next_pieces_tween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	next_pieces_tween.tween_property(next_pieces_grid, "position", Vector3(0, 4, 0), 1)
	
	for i in current_shown_pieces:
		next_pieces_grid.set_cell_item(i, -1)
	
	next_pieces_grid.position.y = 0
	
	for piece in pieces:
		for pos in piece[0]:
			var cell_position = convert_vec2_vec3(pos) + Vector3i(8, 26 - vertical_offset, 0)
			current_shown_pieces.append(cell_position)
			next_pieces_grid.set_cell_item(cell_position, active_table.shapes.find(piece))
		vertical_offset += 4

#handles new piece creation
func create_piece():
	counting = false
	check_rows()
	steps = [0, 0, 0]
	current_loc = SPAWN
	rotation_index = 0
	detect_lost()
	
	if !lost:
		can_hold = true
		
		if piece_type == active_table.t:
			print(tspin_valid)
		
		piece_type = next_pieces[0]
		piece_color = active_table.shapes.find(piece_type)
		next_piece()
	
		active_piece = piece_type[rotation_index]
		draw_piece(active_piece, SPAWN)
		show_held_piece(held_piece, held_piece_color)
		draw_top()
		tspin_valid = false

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
	var temp_rotation_index 
	match dir:
			"left":
				temp_rotation_index = (rotation_index + 3) % 4
			"right":
				temp_rotation_index = (rotation_index + 1) % 4
				
	var srs_kick_table : Array = active_table.get(("n" if piece_type != active_table.i else "i")\
	 + str(rotation_index) + str(temp_rotation_index))
	var temp_kick_table = srs_kick_table.duplicate()
	temp_kick_table.push_front(Vector2i(0,0))
	
	for i in range(temp_kick_table.size()):
		var offset = temp_kick_table[i]
		if can_rotate(temp_rotation_index, offset):
			temp_timer = 0
			clear_piece()
			rotation_index = temp_rotation_index

			active_piece = piece_type[rotation_index]
			current_loc.x += offset.x
			current_loc.y += offset.y
			draw_piece(active_piece, current_loc)

		# Check if the offset is the first or the last in the list
			if piece_type == active_table.t:
				if i == 0 or i == temp_kick_table.size() - 1:
					if detect_tspin():
						tspin_valid = true
					else:
						tspin_valid = false
			return
	
#checks if the piece can perform a valid rotation
func can_rotate(temp_rot_idx, offset):
	for block_position in piece_type[temp_rot_idx]: # Check each block in the piece
		var next_pos = convert_vec2_vec3(block_position) + current_loc
		next_pos.x += offset.x
		next_pos.y += offset.y
		if not is_free(next_pos, true): # If any position is not free
			return false
	
	return true

#hmmmm
func detect_tspin():
	var current_3x3 = []
	for j in grid_3x3_corners:
		var grid_space = convert_vec2_vec3(j) + current_loc
		current_3x3.append(grid_space)
	#current_3x3.pop_at(rotation_index)
	var in_front = []
	#for j in current_3x3:
	print(str(current_3x3) + " CORNERS FOR " + str(rotation_index))
	for l in range(2):
		in_front.append(current_3x3.pop_at((rotation_index % 4) - 1))
		
	for j in in_front:
		set_cell_item(j, 8)
	print(str(in_front) + " IN FRONT")

#moves the piece in a specified direction
func move_piece(dir):
	if can_move(dir):
		clear_piece()
		current_loc += convert_vec2_vec3(dir)
		draw_piece(active_piece, current_loc)
		is_free_below()
		temp_timer = 0
		tspin_valid = false

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
			piece_color = active_table.shapes.find(piece_type)
			
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
		for col in range(-COLS/2.0, COLS/2.0):
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
		for col in range(-COLS/2.0, COLS/2.0):
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
			for col in range(-COLS/2.0, COLS/2.0):
				var item_col = get_cell_item(Vector3i(col, row, 0))
				if !is_free(Vector3i(col, row, 0)):
					set_cell_item(Vector3i(col, row - rows_to_move_down, 0), item_col)
					set_cell_item(Vector3i(col, row, 0), -1)
			if soft_dropping:
				change_gravity(ACCEL / SDF, true)
			else:
				change_gravity(ACCEL, true)
			
			animation_player.stop()
			cleared.text = cleared_lines[rows_to_move_down]
			animation_player.play("lines_cleared")
			
#how did i get 3d buttons to work
func _on_button_input_event(_camera, event, _position, _normal, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed == true:
			new_game()

#clears the board
func clear_board():
	for y in range(-10, 20):
		@warning_ignore("integer_division", "integer_division")
		for x in range(-COLS/2.0, COLS/2.0):
			set_cell_item(Vector3i(x, y, 0), -1)

#detects if you lost the game
func detect_lost():
	@warning_ignore("integer_division")
	for x in range(-COLS/2.0 , COLS/2.0 ):
		if !is_free(Vector3i(x, 11, 0), true):
			game_lost()
			
#handles losing
func game_lost():
	gameover.visible = true
	lost = true

#toggles rtx 🕶️
func _on_pause_menu_toggle_rtx(on_off):
	env.sdfgi_enabled = on_off

#handles everything related to changing the gravity
func change_gravity(value : float, increase_mode := false):
	if increase_mode:
		active_gravity -= value
	else: 
		active_gravity = value
	
	active_gravity = clamp(active_gravity,0.1,INF)
	
#modifies the handling from the settings
func _on_pause_menu_modify_handling(setting, value):
	soft_dropping = false
	set(setting, value)

#handles pausing the actual game
func _on_pause_menu_pause_state(pause_state):
	if pause_state:
		paused = true
		animation_player.speed_scale = 0	
	elif not pause_state:
		paused = false
		animation_player.speed_scale = 1

#checks if the moving down is valid, used for lock delay
func is_free_below():
	for i in active_piece:
		if !is_free(convert_vec2_vec3(i + Vector2i(0, 1)) + current_loc, true):
			counting = true
			return
		else:
			counting = false
