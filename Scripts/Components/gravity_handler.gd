class_name GravityHandler
extends BaseComponent



@export var levels: LevelHandler
@export var starter_gravity := 1.0

var grav_counter: float
var gravity: float = 1.0:
	set(value):
		gravity = value
	get:
		return gravity if !active_piece.soft_dropping else (gravity / 3) / Settings.sdf

func _ready() -> void:
	levels.updated_values.connect(func() -> void:
		update_gravity())

	active_piece.piece_placed.connect(func() -> void:
		grav_counter = 0)

	get_parent().game_start.connect(func() -> void:
		gravity = starter_gravity)

func _process(delta: float) -> void:
	if parent.lost or parent.paused:
		return

	grav_counter += delta
	if grav_counter > gravity:
		active_piece.move_piece(get_parent().directions[2])
		grav_counter = 0

func update_gravity() -> void:
	gravity = calculate_gravity_curve(levels.level)

## The official gravity scaling system for guideline Tetris
func calculate_gravity_curve(level: int) -> float:
	return (0.8 - ((level - 1) * 0.007)) ** (level - 1)
