class_name ScoreHandler
## Handles everything related to the score
extends BaseComponent

## Set to either [Label] or [Label3D]
@export var label: Node
@export var score_table: ScoreTable

## TODO also make soft dropping and hard dropping

var score: int

func _ready() -> void:
	if not "text" in label:
		push_error("Label is not valid")
		assert(false)

	get_parent().update_score.connect(handle_score)

	get_parent().game_start.connect(func() -> void:
		score = 0
		label.text = str(score))

func handle_score(lines_cleared_count: int, tspin_valid: int) -> void:
	var counted := false
	if tspin_valid == 2:
		score += score_table.standard_tspin[lines_cleared_count]
		counted = true
	elif tspin_valid == 1:
		score += score_table.mini_tspin[lines_cleared_count]
		counted = true
	if !counted and lines_cleared_count > 0:
		score += score_table.basic[lines_cleared_count]
	label.text = str(score)
