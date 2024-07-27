class_name GameStateHandler
extends BaseComponent

@export var death_screen: Node

func _ready() -> void:
	death_screen.hide()
	parent.piece_placed.connect(func() -> void:
		check_death())

	death_screen.find_child("Button").input_event.connect(\
			func(_camera:Node, \
				event:InputEvent, \
				_position:Vector3, \
				_normal:Vector3, \
				_shape_idx:int) -> void:

			if event is InputEventMouseButton:
				if event.button_mask == MOUSE_BUTTON_LEFT:
					if event.pressed:
						parent.new_game()
						parent.lost = false)

func check_death() -> void:
	for i: int in parent.game[2]:
		if i != -1:
			print("Ah")
			parent.lost = true
			death_screen.show()
			break
