class_name AllClearHandler
extends BaseComponent

@export var label: Node

func _ready() -> void:
	parent.lines_cleared.connect(func(lines: Array[int], _piece_color: int) -> void:
		detect_all_clear())

func detect_all_clear() -> void:
	for row in parent.game:
		for cell: int in row:
			if cell != -1:
				label.text = ""
				return
	label.text = "Clear"
