class_name InputButton
extends Button

var arrows = ["Left", "Right", "Down", "Up"]

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
		print(keycode)
		if str(keycode) in arrows:
			text = keycode + " Arrow"
		else:
			text = str(keycode)
		input_found.emit(keycode)
