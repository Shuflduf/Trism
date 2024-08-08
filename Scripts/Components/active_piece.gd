class_name ActivePiece
extends BaseComponent

signal piece_moved
signal piece_placed

@export var SPAWN := Vector2i(3, 1)
@export var active_table : KickTable

var grid_3x3_corners := [Vector2i(0, 0), Vector2i(2, 0), Vector2i(2, 2), Vector2i(0, 2)]

var moving_dir := [false, false, false]
var soft_dropping := false

var drop_timer := 0
var temp_timer := 0
const MAX_DROP_TIME = 120
const TEMP_DROP_TIME = 40

var piece_type : Array

var rotation_index : int = 0
#var active_piece_type : Array
var current_loc : Vector2i
var piece_color : int

var current_dcd := Settings.dcd
const directions := [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.DOWN]
var dir_timers := [0, 0]
var counting := false


enum TSpin {
	NONE,
	FULL,
	MINI
}

var tspin_valid : TSpin

func _ready() -> void:
	parent.game_start.connect(start)

func start() -> void:
	await parent.animation_player.animation_finished
	parent.lost = false
	create_piece()


@warning_ignore("unused_parameter")
func draw_piece(piece: Array, pos: Vector2i) -> void:
	#for i: Vector2i in piece:
		#parent.game[i.y + pos.y][i.x + pos.x] = parent.piece_color
	#update_board.emit()
	piece_moved.emit()

func _unhandled_key_input(event: InputEvent) -> void:
	if parent.lost or parent.paused:
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

func _physics_process(_delta: float) -> void:

	if parent.lost or parent.paused:
		return
	current_dcd -= 1
	print(piece_type[rotation_index])
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

func create_piece() -> void:
	counting = false
	parent.check_rows(piece_color)
	current_loc = SPAWN
	rotation_index = 0

	if !parent.lost:
		current_dcd = Settings.dcd

		piece_type = active_table.shapes.pick_random()
		piece_placed.emit()
		if parent.lost:
			return

		piece_color = active_table.shapes.find(piece_type)

		#active_piece_type = piece_type[rotation_index]
		#draw_piece(piece_type[rotation_index], current_loc)


		#parent.update_score.emit(lines_just_cleared, tspin_valid) #TODO
		tspin_valid = TSpin.NONE
		parent.lines_just_cleared = 0
		if Input.is_action_pressed("soft"):
			if Settings.sonic:
				while can_move(directions[2]):
					move_piece(directions[2])

#func clear_piece() -> void:
	#for i: Vector2i in active_piece:
		#game[i.y + current_loc.y][i.x + current_loc.x] = -1

func transfer_current_piece() -> void:
	for i: Vector2i in piece_type[rotation_index]:
		parent.game[i.y + current_loc.y][i.x + current_loc.x] = piece_color


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
	var temp_kick_table := srs_kick_table + [Vector2i(0,0)]
	#temp_kick_table.push_front))

	for i in range(temp_kick_table.size()):
		var offset: Vector2i = temp_kick_table[i]
		if can_rotate(temp_rotation_index, offset):
			temp_timer = 0
			#clear_piece()
			rotation_index = temp_rotation_index

			#active_piece = piece_type[rotation_index]

			current_loc += offset
			#draw_piece(active_piece_type, current_loc)
			current_dcd = Settings.dcd


		 # Check if the offset is the first or the last in the list
			if piece_type == active_table.t:
				match detect_tspin(i):
					TSpin.FULL:
						tspin_valid = TSpin.FULL
					TSpin.MINI:
						tspin_valid = TSpin.MINI
					_:
						tspin_valid = TSpin.NONE
			break

# checks if the piece can perform a valid rotation
func can_rotate(temp_rot_idx: int, offset: Vector2i) -> bool:
	for block_position: Vector2i in piece_type[temp_rot_idx]: # Check each block in the piece
		var next_pos := block_position + current_loc
		next_pos.x += offset.x
		next_pos.y += offset.y
		if not is_free(next_pos): # If any position is not free
			return false

	return true

#hmmmm
func detect_tspin(kick: int) -> TSpin:
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
				return TSpin.NONE
		for i: Vector2i in on_back:
			if !is_free(i):
				return TSpin.FULL

	elif kick == 4:
		for i: Vector2i in on_back:
			if is_free(i):
				return TSpin.NONE
		for i: Vector2i in on_front:
			if !is_free(i):
				return TSpin.FULL

	else:
		for i: Vector2i in on_back:
			if is_free(i):
				return TSpin.NONE
		for i: Vector2i in on_front:
			if !is_free(i):
				return TSpin.MINI

	return TSpin.NONE

#moves the piece in a specified direction
func move_piece(dir: Vector2i) -> void:
	if can_move(dir):
		#clear_piece()
		current_loc += dir

		#draw_piece(active_piece_type, current_loc)
		is_free_below()
		temp_timer = 0
		tspin_valid = TSpin.NONE

#checks if the piece can move in a specified direction
func can_move(dir: Vector2i) -> bool:
	var cm := true
	for square: Vector2i in piece_type[rotation_index]:
		var next_pos := square + current_loc + dir
		if not is_free(next_pos):
			cm = false
			break
	return cm

#helper function that checks if a current grid space is free
func is_free(pos: Vector2i) -> bool:

	#for i: int in TRANSPARENT_PIECES:
		#if get_cell_item(pos) == i: TODO
	#print(pos)
	if pos.y >= parent.game.size() or pos.x >= parent.game[0].size() or pos.x < 0:
		return false

	if parent.game[pos.y][pos.x] == -1:
		return true
	return false

func hard_drop() -> void:

	while can_move(directions[2]):
		move_piece(directions[2])
	create_piece()

func is_free_below() -> void:
	for i: Vector2i in piece_type[rotation_index]:
		if !is_free(i + Vector2i(0, 1) + current_loc):
			counting = true
			return
		else:
			counting = false
