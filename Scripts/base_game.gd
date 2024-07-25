@icon("res://Assets/Editor/tetris.png")

class_name BaseGame
extends Node

signal piece_placed
signal game_start

signal update_score(lines: int, tspin: String)

@export var active_table : SRS

@onready var gameover := $"../UI/Gameover"
@onready var animation_player := %AnimationPlayer
#@onready var env: Environment = %WorldEnvironment.environment
@onready var cleared := %Cleared
@onready var tspin_label := %Tspin
@onready var camera := %Camera3D


var cleared_lines := {
	1 : "One",
	2 : "Two",
	3 : "Three",
	4 : "Four",
}

var tspins_text := {
	"mini" : "MINI T SPUN",
	"standard" : "T SPUN",
}

const camera_positions = [Vector3(0, 1, 35), Vector3(0, -31, 13)]
const camera_rotations = [Vector3.ZERO, Vector3(60, 0, 0)]

var grid_3x3_corners := [Vector2i(0, 0), Vector2i(2, 0), Vector2i(2, 2), Vector2i(0, 2)]

var moving_dir := [false, false, false]
var soft_dropping := false

#grid consts
const ROWS := 20
const COLS := 10
@export var SPAWN := Vector2i(4, 0)
#const TRANSPARENT_PIECES = [-1]

#game state vars
var lost := false
var paused := false
#var can_hold := true

#game piece vars
var counting := false
var drop_timer := 0
var temp_timer := 0
const MAX_DROP_TIME = 120
const TEMP_DROP_TIME = 40

var lines_just_cleared := 0
var tspin_valid := "false" # standard, mini, false
var piece_type : Array


var rotation_index : int = 0
var active_piece : Array
var current_loc : Vector2i
#var ghost_positions : Array

#var held_piece := []
#var held_piece_color: int
#var current_held_piece : Array

#grid vars
var piece_color : int

#movement variables
var current_dcd := Settings.dcd
const directions := [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.DOWN]
var dir_timers := [0, 0]


## THE BIG BOI

var game: Array[Array] # game[row][col]


func setup_board() -> void:
	game.resize(ROWS)
	for row in game:
		row.resize(COLS)


	for row in ROWS:
		for col in COLS:
			game[row][col] = -1


func debug_game_arr() -> void:

	#return

	for row in game:
		print(row)
	print("  ------  ")

#initilize
func _init() -> void:
	PauseMenu.pause_state.connect(func(pause_state: bool) -> void:
		_on_pause_menu_pause_state(pause_state))
	#Settings.settings_changed.connect(func() -> void:
		#_on_settings_changed())

#handles initial game run
func _ready() -> void:
	#set_cinematic_camera()
	#animation_player.play("RESET")
	#animation_player.assigned_animation = "countdown"
	lost = true
	randomize()
	await SceneManager.transitioned_out
	new_game()

#handles what happens every frame
func _physics_process(_delta: float) -> void:

	if lost or paused:
		return
	current_dcd -= 1

	# Handle DAS for left movement
	if moving_dir[0]:
		dir_timers[0] += 1
		if dir_timers[0] > Settings.das and current_dcd < 0:
			if dir_timers[0] % Settings.arr == 0:
				move_piece(directions[0])
	else:
		dir_timers[0] = 0

	# Handle DAS for right movement
	if moving_dir[1]:
		dir_timers[1] += 1
		if dir_timers[1] > Settings.das and current_dcd < 0:
			if dir_timers[1] % Settings.arr == 0:
				move_piece(directions[1])
	else:
		dir_timers[1] = 0



	if counting:
		drop_timer += 1
		temp_timer += 1
		if temp_timer > TEMP_DROP_TIME or drop_timer > MAX_DROP_TIME:
			drop_timer = 0
			temp_timer = 0
			hard_drop()


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		PauseMenu.handle_pause()

	elif event.is_action_pressed("left"):
		move_piece(directions[0])
		moving_dir[0] = true
		moving_dir[1] = false

	elif Input.is_action_pressed("right"):
		move_piece(directions[1])
		moving_dir[0] = false
		moving_dir[1] = true

	elif event.is_action_released("left"):
		if Input.is_action_pressed("right"):
			move_piece(directions[1])
			moving_dir[1] = true
		moving_dir[0] = false

	elif event.is_action_released("right"):
		if Input.is_action_pressed("left"):
			move_piece(directions[0])
			moving_dir[0] = true
		moving_dir[1] = false

	elif event.is_action_pressed("soft"):
		soft_dropping = true
		#change_gravity(active_gravity)
		if Settings.sonic:
			while can_move(directions[2]):
				move_piece(directions[2])

	elif event.is_action_released("soft"):
		soft_dropping = false

	# Other controls
	if event.is_action_pressed("hard"):
		hard_drop()
	#elif event.is_action_pressed("hold"):
		#hold_piece()
	#elif event.is_action_pressed("rot_left"):
		#rotate_piece("left")
	#elif event.is_action_pressed("rot_right"):
		#rotate_piece("right")

#handles everything when starting a new game
func new_game() -> void:
	#clear_held_piece()
	#clear_board()
	#draw_top()
	setup_board()
	game_start.emit()

	#gravity = STARTER_GRAV

	gameover.hide()
	animation_player.play("countdown")
	await animation_player.animation_finished
	lost = false




	#held_piece = []
	create_piece()


#handles new piece creation
func create_piece() -> void:
	counting = false
	check_rows()
	current_loc = SPAWN
	rotation_index = 0
	#detect_lost()

	if !lost:
		current_dcd = Settings.dcd
		#can_hold = true


		piece_type = active_table.shapes.pick_random()
		piece_placed.emit()

		piece_color = active_table.shapes.find(piece_type)


		active_piece = piece_type[rotation_index]
		draw_piece(active_piece, current_loc)
		#show_held_piece(held_piece, held_piece_color)
		#draw_top()


		update_score.emit(lines_just_cleared, tspin_valid)
		update_lines_cleared_tspin_labels(lines_just_cleared, tspin_valid)
		tspin_valid = "false"
		lines_just_cleared = 0
		if Input.is_action_pressed("soft"):
			if Settings.sonic:
				while can_move(directions[2]):
					move_piece(directions[2])

#clears the drawn piece to avoid ghosting
func clear_piece() -> void:
	for i: Vector2i in active_piece:
		game[i.y + current_loc.y][i.x + current_loc.x] = -1

#draws the piece
func draw_piece(piece: Array, pos: Vector2i) -> void:
	#draw_top()
	#handle_ghost()
	for i: Vector2i in piece:
		game[i.y + pos.y][i.x + pos.x] = piece_color
		#set_cell_item(convert_vec2_vec3(i) + pos, piece_color)
	debug_game_arr()

#rotates the piece
#func rotate_piece(dir: String) -> void:
	#var temp_rotation_index: int
	#match dir:
		#"left":
			#temp_rotation_index = (rotation_index + 3) % 4
		#"right":
			#temp_rotation_index = (rotation_index + 1) % 4
#
	#var srs_kick_table : Array = active_table.get(\
			#("n" if piece_type != active_table.i else "i")\
	 		#+ str(rotation_index) + str(temp_rotation_index))
	#var temp_kick_table := srs_kick_table.duplicate()
	#temp_kick_table.push_front(Vector2i(0,0))
#
	#for i in range(temp_kick_table.size()):
		#var offset: Vector2i = temp_kick_table[i]
		#if can_rotate(temp_rotation_index, offset):
			#temp_timer = 0
			##clear_piece() TODO
			#rotation_index = temp_rotation_index
#
			#active_piece = piece_type[rotation_index]
			#current_loc.x += offset.x
			#current_loc.y += offset.y
			##draw_piece(active_piece, current_loc) TODO
			#current_dcd = Settings.dcd


		# Check if the offset is the first or the last in the list
			#if piece_type == active_table.t:
				#match detect_tspin(i):
					#"standard":
						#tspin_valid = "standard"
					#"mini":
						#tspin_valid = "mini"
					#_:
						#tspin_valid = "false"
			#break

#checks if the piece can perform a valid rotation
#func can_rotate(temp_rot_idx: int, offset: Vector2i) -> bool:
	#for block_position: Vector2i in piece_type[temp_rot_idx]: # Check each block in the piece
		#var next_pos := block_position + current_loc
		#next_pos.x += offset.x
		#next_pos.y += offset.y
		#if not is_free(next_pos, true): # If any position is not free
			#return false
#
	#return true

#hmmmm
#func detect_tspin(kick: int) -> String:
	#var current_3x3 := []
	#for j: Vector2i in grid_3x3_corners:
		#var grid_space := j + current_loc
		#current_3x3.append(grid_space)
#
	#var on_front := []
	#for i in range(2):
		#on_front.append(current_3x3[(rotation_index + i) % 4])
#
#
	#var on_back := []
	#for i in range(2):
		#on_back.append(current_3x3[(rotation_index + i + 2) % 4])
#
	#if kick == 0:
		#for i: Vector2i in on_front:
			#if is_free(i):
				#return "false"
		#for i: Vector2i in on_back:
			#if !is_free(i):
				#return "standard"
#
	#elif kick == 4:
		#for i: Vector2i in on_back:
			#if is_free(i):
				#return "false"
		#for i: Vector2i in on_front:
			#if !is_free(i):
				#return "standard"
#
	#else:
		#for i: Vector2i in on_back:
			#if is_free(i):
				#return "false"
		#for i: Vector2i in on_front:
			#if !is_free(i):
				#return "mini"
#
	#return "false"

#moves the piece in a specified direction
func move_piece(dir: Vector2i) -> void:
	if can_move(dir):
		clear_piece()
		current_loc += dir
		#print(current_loc)
		draw_piece(active_piece, current_loc)
		is_free_below()
		temp_timer = 0
		tspin_valid = "false"

#checks if the piece can move in a specified direction
func can_move(dir: Vector2i) -> bool:
	var cm := true
	for square: Vector2i in active_piece:
		var next_pos := square + current_loc + dir
		if not is_free(next_pos, true):
			cm = false
			break
	return cm

#helper function that checks if a current grid space is free
func is_free(pos: Vector2i, exclude_active_piece: bool = false) -> bool:
	if exclude_active_piece:
		for block_pos: Vector2i in active_piece:
			if block_pos + current_loc == pos:
				return true
	#for i: int in TRANSPARENT_PIECES:
		#if get_cell_item(pos) == i: TODO
	#print(pos)
	if pos.y > game.size() - 1 or pos.x > game[0].size() - 1 or pos.x < 0:
		return false

	if game[pos.y][pos.x] == -1:
		return true
	return false

#hard drops the piece
func hard_drop() -> void:

	while can_move(directions[2]):
		move_piece(directions[2])
	create_piece()

#all the ghost piece functions bundled together since i didnt feel like writing them everywhere
#func handle_ghost() -> void:
	#clear_ghost()
	#var dist := find_ghost_positions()
	#draw_ghost(dist)

#finds how far the ghost piece has to move down
#func find_ghost_positions() -> int:
	#ghost_positions = []
	#var min_drop_distance := 9999
#
	#for i: Vector2i in active_piece:
		#var drop_distance := 0
		#var ghost_pos := i + current_loc
#
		#while is_free(ghost_pos + Vector2i(0, -1), true):
			#ghost_pos += Vector2i(0, -1)
			#drop_distance += 1
#
		#if drop_distance < min_drop_distance:
			#min_drop_distance = drop_distance
#
	#return min_drop_distance
#
##draws the ghost piece
#func draw_ghost(dist: int) -> void:
	#for i: Vector2i in active_piece:
		#var ghost_pos := i + current_loc + Vector2i(0, -dist)
		#ghost_positions.append(ghost_pos)
		#set_cell_item(ghost_pos, 8)

#clears the current ghost piece before drawing a new one, to avoid "ghosting"
#func clear_ghost() -> void:
	#for i: Vector3i in ghost_positions:
		#if get_cell_item(i) == 8:
			#set_cell_item(i, -1)
	#ghost_positions = []

#handles everything related to holding pieces
#func hold_piece() -> void:
	#if can_hold:
		#held_piece_color = piece_color
		##clear_held_piece()
		#if held_piece == []:
			#held_piece = piece_type
			##clear_piece()
			#create_piece()
		#else:
			##clear_piece()
#
			#var temp_piece := piece_type
			#piece_type = held_piece
			#held_piece = temp_piece
			#current_loc = SPAWN
			#rotation_index = 0
#
			#active_piece = piece_type[rotation_index]
			#piece_color = active_table.shapes.find(piece_type)
#
			##draw_piece(active_piece, current_loc)
#
		##show_held_piece(held_piece, 8)
		#can_hold = false
	#else:
		#show_held_piece(held_piece, 8)

#shows the active held piece
#func show_held_piece(piece: Array, color: int) -> void:
	#if piece != []:
		#for i: Vector2i in piece[0]:
			#var piece_pos := i + Vector2i(-11, -8)
			##set_cell_item(piece_pos, color)
			#current_held_piece.append(piece_pos)

#clear held piece
#func clear_held_piece() -> void:
	#for i: Vector3i in current_held_piece:
		#set_cell_item(i, -1)

#draws that little transparent bar at the top
#func draw_top() -> void:
#
	#for i in COLS:
		#if is_free(Vector3i(i -5, 10, 0)):
			#set_cell_item(Vector3i(i -5, 10, 0), 8)

#checks if any rows are full
func check_rows() -> void:

	var rows_to_clear := []

	for row in range(-ROWS, 10):
		var is_row_full := true

		for col in range(-COLS/2.0, COLS/2.0):
			if is_free(Vector2i(col, row)):
				is_row_full = false
				break

		if is_row_full and row != -11:
			rows_to_clear.append(row)

	#if rows_to_clear.size() > 0:
		#move_down_rows(rows_to_clear)

#clears rows and moves pieces above it down
#func move_down_rows(cleared_rows_indices: Array) -> void:
	#cleared_rows_indices.sort()
	#lines_just_cleared = cleared_rows_indices.size()
#
	## Clear the rows
	#for row: int in cleared_rows_indices:
		#for col in range(-COLS/2.0, COLS/2.0):
			#pass
			##set_cell_item(Vector3i(col, row, 0), -1)
		##lines_cleared += 1
		##lines_cleared_label.text = str(lines_cleared) + " lines"
		##update_level()
#
	## Move pieces down
	#for row in range(cleared_rows_indices[0] + 1, 11):
		#var rows_to_move_down := 0
		#for cleared_row: int in cleared_rows_indices:
			#if row > cleared_row:
				#rows_to_move_down += 1
			#else:
				#break
#
		#if rows_to_move_down > 0:
			#for col in range(-COLS/2.0, COLS/2.0):
				#var item_col: int = get_cell_item(Vector3i(col, row, 0))
				#if !is_free(Vector3i(col, row, 0)):
					#set_cell_item(Vector3i(col, row - rows_to_move_down, 0), item_col)
					#set_cell_item(Vector3i(col, row, 0), -1)

			#gravity += ACCEL


#how did i get 3d buttons to work
#func _on_button_input_event\
		#(_c: Node, event: InputEvent, _position: Vector3, \
		#_normal: Vector3, _shape_idx: int) -> void:
	#if event is InputEventMouseButton:
		#if event.button_index == MOUSE_BUTTON_LEFT and event.pressed == true:
			#new_game()

#clears the board
func clear_board() -> void:
	for row: int in game.size():
		for col: int in game[0].size():
			game[row][col] = Vector2i.ZERO

#detects if you lost the game
func detect_lost() -> void:
	for x in range(0, game[0].size()):
		if !is_free(Vector2i(x, 11), true):
			game_lost()

#handles losing
func game_lost() -> void:
	gameover.visible = true
	lost = true

#toggles rtx 🕶️
#func _on_settings_changed() -> void:
	#set_cinematic_camera()
	#env.sdfgi_enabled = Settings.rtx_on

#modifies the handling from the settings
func _on_pause_menu_modify_handling(setting: Variant, value: Variant) -> void:
	soft_dropping = false
	set(setting, value)

#handles pausing the actual game
func _on_pause_menu_pause_state(pause_state: bool) -> void:
	if pause_state:
		paused = true
		animation_player.speed_scale = 0
	elif not pause_state:
		paused = false
		animation_player.speed_scale = 1

#checks if the moving down is valid, used for lock delay
func is_free_below() -> void:
	for i: Vector2i in active_piece:
		if !is_free(i + Vector2i(0, 1) + current_loc, true):
			counting = true
			return
		else:
			counting = false

#toggles cinematic camera for some reason
func set_cinematic_camera() -> void:
	camera.position = camera_positions[0] if !Settings.cinematic_mode else camera_positions[1]
	camera.rotation_degrees = camera_rotations[0] if !Settings.cinematic_mode else camera_rotations[1]




#changes the value of cleared label and tspin label
func update_lines_cleared_tspin_labels(lines : int, tspin : String) -> void:
	animation_player.stop()
	tspin_label.text = ""
	cleared.text = ""
	if lines != 0:
		cleared.text = cleared_lines[lines]
	if tspin in tspins_text:
		tspin_label.text = tspins_text[tspin]
	animation_player.play("lines_cleared")
