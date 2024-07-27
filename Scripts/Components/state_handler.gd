class_name GameStateHandler
extends BaseComponent

func  _ready() -> void:
	parent.piece_placed.connect(func() -> void:
		check_death())

func check_death() -> void:
	for i: int in parent.game[2]:
		if i != -1:
			print("Ah")
			parent.lost = true
