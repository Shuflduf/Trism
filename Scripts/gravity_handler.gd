class_name GravityHandler
extends Node

@export var levels: LevelHandler

@export var acceleration := 0.01
@export var starter_gravity := 60.0

var grav_counter: float
var gravity: float = 1.0:
	set(value):
		gravity = value
	get:
		return gravity if !get_parent().soft_dropping else (gravity / 3) / Settings.sdf

func _ready() -> void:
	levels.updated_values.connect(func() -> void:
		pass)

func _process(delta: float) -> void:
	grav_counter += delta
	if grav_counter > gravity:
		get_parent().move_piece(get_parent().directions[2])
		grav_counter = 0
