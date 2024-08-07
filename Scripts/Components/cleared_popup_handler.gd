class_name LinesTspinPopupHandler
extends BaseComponent

@export var just_cleared_label: Node
@export var just_tspin_label: Node
@export var animation_player: AnimationPlayer

var cleared_lines := {
	1 : "One",
	2 : "Two",
	3 : "Three",
	4 : "Four",
}

var tspins_text := {
	"mini" : "MINI T SPUN",
	"standard" : "T SPUN",
}

func _ready() -> void:
	if not "text" in just_cleared_label or not "text" in just_tspin_label:
		push_error("Label is not valid")
		assert(false)

	parent.update_score.connect(update_lines_cleared_tspin_labels)

func update_lines_cleared_tspin_labels(lines : int, tspin : String) -> void:
	animation_player.stop()
	just_tspin_label.text = ""
	just_cleared_label.text = ""
	if lines != 0:
		just_cleared_label.text = cleared_lines[lines]
	if tspin in tspins_text:
		just_tspin_label.text = tspins_text[tspin]
	animation_player.play("lines_cleared")
