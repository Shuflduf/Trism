class_name GravityHandler
extends BaseComponent

@export var levels: LevelHandler
@export var starter_gravity := 1.0

var counting := false

var grav_counter: float
var gravity: float = 1.0:
	set(value):
		gravity = value
	get:
		return gravity if !active_piece.soft_dropping else (gravity / 3) / Settings.sdf

var drop_timer := 0.0
var temp_timer := 0.0
const MAX_DROP_TIME = 2.0
const TEMP_DROP_TIME = 0.666667

func _ready() -> void:
	levels.updated_values.connect(func() -> void:
		update_gravity())

	active_piece.piece_placed.connect(func() -> void:
		counting = false
		grav_counter = 0)

	active_piece.piece_moved.connect(func() -> void:
		is_free_below()
		temp_timer = 0)

	get_parent().game_start.connect(func() -> void:
		gravity = starter_gravity)

func _process(delta: float) -> void:
	if parent.lost or parent.paused:
		return

	grav_counter += delta
	if grav_counter > gravity:
		active_piece.move_piece(active_piece.directions[2])
		grav_counter = 0

	if counting:
		drop_timer += delta
		temp_timer += delta
		if temp_timer > TEMP_DROP_TIME or drop_timer > MAX_DROP_TIME:
			drop_timer = 0
			temp_timer = 0
			active_piece.hard_drop()

func update_gravity() -> void:
	gravity = calculate_gravity_curve(levels.level)

## The official gravity scaling system for guideline Tetris
func calculate_gravity_curve(level: int) -> float:
	return (0.8 - ((level - 1) * 0.007)) ** (level - 1)

func is_free_below() -> void:

	if active_piece.piece_type == []:
		return

	for i: Vector2i in active_piece.piece_type[active_piece.rotation_index]:
		if !active_piece.is_free(i + Vector2i(0, 1) + active_piece.current_loc):
			counting = true
			return
		else:
			counting = false
