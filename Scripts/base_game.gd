@icon("res://Assets/Editor/tetris.png")

class_name BaseGame
extends Node

signal piece_placed
signal game_start
signal update_board
signal piece_moved

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
const ROWS := 22
const COLS := 10
@export var SPAWN := Vector2i(3, 1)
#const TRANSPARENT_PIECES = [-1]

#game state vars
var lost := false
var paused := false


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



#grid vars
var piece_color : int

#movement variables
var current_dcd := Settings.dcd
const directions := [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.DOWN]
var dir_timers := [0, 0]


## THE BIG BOI

var game: Array[Array] # game[row][col] when accessing, do y then x


func setup_board() -> void:
	game.resize(ROWS)
	for row in game:
		row.resize(COLS)


	for row in ROWS:
		for col in COLS:
			game[row][col] = -1

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

	if lost or paused:
		return

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
		if Settings.sonic:
			while can_move(directions[2]):
				move_piece(directions[2])

	elif event.is_action_released("soft"):
		soft_dropping = false

	# Other controls
	if event.is_action_pressed("hard"):
		hard_drop()

	elif event.is_action_pressed("rot_left"):
		rotate_piece("left")
	elif event.is_action_pressed("rot_right"):
		rotate_piece("right")

#handles everything when starting a new game
func new_game() -> void:
	#clear_held_piece()
	#clear_board()
	#draw_top()
	setup_board()
	update_board.emit()
	game_start.emit()


	gameover.hide()
	animation_player.play("countdown", -1, 3)
	await animation_player.animation_finished
	lost = false


	create_piece()


#handles new piece creation
func create_piece() -> void:
	counting = false
	check_rows()
	current_loc = SPAWN
	rotation_index = 0

	if !lost:
		current_dcd = Settings.dcd

		piece_type = active_table.shapes.pick_random()
		piece_placed.emit()
		if lost:
			return

		piece_color = active_table.shapes.find(piece_type)

		active_piece = piece_type[rotation_index]
		draw_piece(active_piece, current_loc)

		update_score.emit(lines_just_cleared, tspin_valid)

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
	#debug_game_arr()
	update_board.emit()
	piece_moved.emit()

#rotates the piece
func rotate_piece(dir: String) -> void:
	var temp_rotation_index: int
	match dir:
		"left":
			temp_rotation_index = (rotation_index + 3) % 4
		"right":
			temp_rotation_index = (rotation_index + 1) % 4

	var srs_kick_table : Array = active_table.get(\
			("n" if piece_type != active_table.i else "i")\
	 		+ str(rotation_index) + str(temp_rotation_index))
	var temp_kick_table := srs_kick_table.duplicate()
	temp_kick_table.push_front(Vector2i(0,0))

	for i in range(temp_kick_table.size()):
		var offset: Vector2i = temp_kick_table[i]
		if can_rotate(temp_rotation_index, offset):
			temp_timer = 0
			clear_piece()
			rotation_index = temp_rotation_index

			active_piece = piece_type[rotation_index]

			current_loc += offset
			draw_piece(active_piece, current_loc)
			current_dcd = Settings.dcd


		 # Check if the offset is the first or the last in the list
			if piece_type == active_table.t:
				match detect_tspin(i):
					"standard":
						tspin_valid = "standard"
					"mini":
						tspin_valid = "mini"
					_:
						tspin_valid = "false"
			break

# checks if the piece can perform a valid rotation
func can_rotate(temp_rot_idx: int, offset: Vector2i) -> bool:
	for block_position: Vector2i in piece_type[temp_rot_idx]: # Check each block in the piece
		var next_pos := block_position + current_loc
		next_pos.x += offset.x
		next_pos.y += offset.y
		if not is_free(next_pos, true): # If any position is not free
			return false

	return true

#hmmmm
func detect_tspin(kick: int) -> String:
	var current_3x3 := []
	for j: Vector2i in grid_3x3_corners:
		var grid_space := j + current_loc
		current_3x3.append(grid_space)

	var on_front := []
	for i in range(2):
		on_front.append(current_3x3[(rotation_index + i) % 4])


	var on_back := []
	for i in range(2):
		on_back.append(current_3x3[(rotation_index + i + 2) % 4])

	if kick == 0:
		for i: Vector2i in on_front:
			if is_free(i):
				return "false"
		for i: Vector2i in on_back:
			if !is_free(i):
				return "standard"

	elif kick == 4:
		for i: Vector2i in on_back:
			if is_free(i):
				return "false"
		for i: Vector2i in on_front:
			if !is_free(i):
				return "standard"

	else:
		for i: Vector2i in on_back:
			if is_free(i):
				return "false"
		for i: Vector2i in on_front:
			if !is_free(i):
				return "mini"

	return "false"

#moves the piece in a specified direction
func move_piece(dir: Vector2i) -> void:
	if can_move(dir):
		clear_piece()
		current_loc += dir

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
	if pos.y >= game.size() or pos.x >= game[0].size() or pos.x < 0:
		return false

	if game[pos.y][pos.x] == -1:
		return true
	return false

#hard drops the piece
func hard_drop() -> void:

	while can_move(directions[2]):
		move_piece(directions[2])
	create_piece()


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

	for row in game.size():

		var k := true
		for col in game[0].size():
			if game[row][col] == -1:
				k = false

		#if is_row_full and row != -11:
		if k:
			rows_to_clear.append(row)

	if rows_to_clear.size() > 0:
		move_down_rows(rows_to_clear)


func move_down_rows(cleared_rows_indices: Array) -> void:
	cleared_rows_indices.sort()
	lines_just_cleared = cleared_rows_indices.size()

	for i in cleared_rows_indices.size():
		game.pop_at(cleared_rows_indices[i])
		var a: Array[int] = []
		for c in COLS:
			a.append(-1)
		game.push_front(a)
	update_board.emit()




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
#func update_lines_cleared_tspin_labels(lines : int, tspin : String) -> void:
	#animation_player.stop()
	#tspin_label.text = ""
	#cleared.text = ""
	#if lines != 0:
		#cleared.text = cleared_lines[lines]
	#if tspin in tspins_text:
		#tspin_label.text = tspins_text[tspin]
	#animation_player.play("lines_cleared")
