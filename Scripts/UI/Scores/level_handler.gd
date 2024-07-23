class_name LevelHandler
extends Node

@export var level_label: Node
@export var lines_label: Node

var lines_cleared := 0
var level := 0

func _ready() -> void:
	get_parent().update_score.connect(func(lines: int, _tspin: String) -> void:
		lines_cleared += lines
		update_values())

	get_parent().game_start.connect(func() -> void:
		level = 0
		lines_cleared = 0
		update_values())

func update_values() -> void:
	level = floor(lines_cleared / 10.0)

	level_label.text = "level " + str(level)
	lines_label.text = str(lines_cleared) + " level"