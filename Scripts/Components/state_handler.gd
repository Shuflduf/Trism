class_name GameStateHandler
extends BaseComponent

@export var death_screen: Node

func _ready() -> void:
	death_screen.hide()
	parent.piece_placed.connect(func() -> void:
		check_death())

	death_screen.find_child("Button").input_event.connect(\
		func(camera:Node, \
				event:InputEvent, \
				position:Vector3, \
				normal:Vector3, \
				shape_idx:int) -> void:
			if !event is InputEventMouseButton:
				if event.button_mask == MOUSE_BUTTON_LEFT:
					parent.new_game()
					parent.lost = false)

func check_death() -> void:
	for i: int in parent.game[2]:
		if i != -1:
			print("Ah")
			parent.lost = true
			death_screen.show()
			break
