extends Node

var custom_inputs := [KEY_UNKNOWN, KEY_UNKNOWN, KEY_UNKNOWN, KEY_UNKNOWN, KEY_UNKNOWN, KEY_UNKNOWN, KEY_UNKNOWN]

signal updated_keybinds(keys: Array)

@onready var set_left := %SetLeft
@onready var set_right := %SetRight
@onready var set_soft := %SetSoft
@onready var set_hard := %SetHard
@onready var set_ccw := %SetCCW
@onready var set_cw := %SetCW
@onready var set_hold := %SetHold

@onready var input_buttons := [set_left, set_right, set_soft, set_hard, set_ccw, set_cw, set_hold]

func _ready() -> void:
	updated_keybinds.emit(custom_inputs)
	for button: InputButton in input_buttons:
		button.looking_input.connect(func() -> void:
			cancel_all_look())
		button.input_found.connect(func(value: String) -> void:
			update_custom_keybinds(button, value))

func cancel_all_look() -> void:
	for button: InputButton in input_buttons:
		button.looking_for_input = false

func update_custom_keybinds(button: InputButton, value: String) -> void:

	var input_index := input_buttons.find(button)
	custom_inputs.remove_at(input_index)
	custom_inputs.insert(input_index, OS.find_keycode_from_string(value))
	updated_keybinds.emit(custom_inputs)




