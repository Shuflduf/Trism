@icon("res://Assets/Editor/tetris.png")

class_name BaseGame
extends Node

signal game_start


signal update_board


signal lines_cleared(lines: Array[int], piece_color: int)
signal update_score(lines: int, tspin: String)



@onready var gameover := $"../UI/Gameover"
@onready var animation_player := %AnimationPlayer
#@onready var env: Environment = %WorldEnvironment.environment
@onready var cleared := %Cleared
@onready var tspin_label := %Tspin
@onready var camera := %Camera3D




const camera_positions = [Vector3(0, 1, 35), Vector3(0, -31, 13)]
const camera_rotations = [Vector3.ZERO, Vector3(60, 0, 0)]



#grid consts
const ROWS := 22
const COLS := 10



#game state vars
var lost := false
var paused := false


#game piece vars



var lines_just_cleared := 0



#grid vars


#movement variables



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



func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		PauseMenu.handle_pause()

#handles everything when starting a new game
func new_game() -> void:
	setup_board()
	update_board.emit()
	game_start.emit()



	gameover.hide()
	animation_player.play("countdown", -1, 3)
	await animation_player.animation_finished
	lost = false



#checks if any rows are full
func check_rows() -> void:

	var rows_to_clear: Array[int] = []

	for row in game.size():

		var k := true
		for col in game[0].size():
			if game[row][col] == -1:
				k = false

		if k:
			rows_to_clear.append(row)

	if rows_to_clear.size() > 0:
		move_down_rows(rows_to_clear)
		lines_cleared.emit(rows_to_clear, piece_color)


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

func is_free(pos: Vector2i, exclude_active_piece: bool = false) -> bool:

	if pos.y >= game.size() or pos.x >= game[0].size() or pos.x < 0:
		return false

	if game[pos.y][pos.x] == -1:
		return true
	return false




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
	#soft_dropping = false
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


#toggles cinematic camera for some reason
#func set_cinematic_camera() -> void:
	#camera.position = camera_positions[0] if !Settings.cinematic_mode else camera_positions[1]
	#camera.rotation_degrees = camera_rotations[0] if !Settings.cinematic_mode else camera_rotations[1]


