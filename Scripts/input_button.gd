class_name InputButton
extends Button

signal looking_input

signal input_found(key_name)

var looking_for_input
var saved_input

func _pressed():
	looking_input.emit()
	looking_for_input = true

func _input(event):
	if looking_for_input and event is InputEventKey:
		var keycode = OS.get_keycode_string(event.key_label)
		looking_for_input = false
		saved_input = keycode
		text = str(saved_input)
		input_found.emit(saved_input)
