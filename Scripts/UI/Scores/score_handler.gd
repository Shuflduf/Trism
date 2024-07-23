class_name ScoreHandler
## Handles everything related to the score
extends Node

## Set to either [Label] or [Label3D]
@export var label: Node
@export var score_table: ScoreTable

## TODO also make soft dropping and hard dropping

var score: int

func _ready() -> void:
	get_parent().update_score.connect(func(lines: int, tspin: String) -> void:
		handle_score(lines, tspin))

	get_parent().game_start.connect(func() -> void:
		score = 0)

func handle_score(lines_cleared_count: int, tspin_valid: String) -> void:
	var counted := false
	if tspin_valid == "standard":
		score += score_table.standard_tspin[lines_cleared_count]
		counted = true
	if tspin_valid == "mini":
		score += score_table.mini_tspin[lines_cleared_count]
		counted = true
	if !counted and lines_cleared_count > 0:
		score += score_table.basic[lines_cleared_count]
	label.text = str(score)
