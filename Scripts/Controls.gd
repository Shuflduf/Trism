extends Node

@export var keybind_resource : PlayerKeybindResource

@onready var set_left = %SetLeft
@onready var set_right = %SetRight
@onready var set_soft = %SetSoft
@onready var set_hard = %SetHard
@onready var set_ccw = %SetCCW
@onready var set_cw = %SetCW
@onready var set_hold = %SetHold

@onready var input_buttons = [set_left, set_right, set_soft, set_hard, set_ccw, set_cw, set_hold]

func stop_looking_all_buttons():
	for i in input_buttons:
		i.cancel_look(i)

func _ready():
	for i in input_buttons:
		i.pressed.connect(stop_looking_all_buttons())

func handle_custom_keybinds():
	pass

func _on_tab_container_tab_changed(tab):
	match tab:
		2:
			switch_keybind_presets(keybind_resource.arrow_keys)
		1:
			switch_keybind_presets(keybind_resource.arrow_keys)
		0:
			switch_keybind_presets(keybind_resource.wasd_keys)

func switch_keybind_presets(preset: Array):
	for i in range(preset.size()):
		var event_key = InputEventKey.new()
		var keycode = preset[i]
		if keycode:
			event_key.keycode = keycode
		else:
			print("Keycode for ", preset[i], " not found in mapping.")
		InputMap.action_erase_events(keybind_resource.input_keys[i])
		InputMap.action_add_event(keybind_resource.input_keys[i], event_key)

