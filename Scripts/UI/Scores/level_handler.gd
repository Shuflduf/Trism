class_name LevelHandler
extends Node

signal updated_values

@export var level_label: Node
@export var lines_label: Node

var lines_cleared := 0
var level := 1

func _ready() -> void:
	get_parent().update_score.connect(func(lines: int, _tspin: String) -> void:
		lines_cleared += lines
		update_values())

	get_parent().game_start.connect(func() -> void:
		level = 1
		lines_cleared = 0
		update_values())

func update_values() -> void:
	level = floor(lines_cleared / 10.0) + 1

	updated_values.emit()

	if level_label != null:
		level_label.text = "level " + str(level)
	if lines_label != null:
		lines_label.text = str(lines_cleared) + " lines"
