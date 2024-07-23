class_name InputButton
extends Button

var arrows := ["Left", "Right", "Down", "Up"]

signal looking_input

signal input_found(key_name: String)

var looking_for_input: bool
var saved_input: String

func _pressed() -> void:
	looking_input.emit()
	looking_for_input = true

func _input(event: InputEvent) -> void:
	if looking_for_input and event is InputEventKey:
		var keycode := OS.get_keycode_string(event.key_label)
		looking_for_input = false
		print(keycode)
		if str(keycode) in arrows:
			text = keycode + " Arrow"
		else:
			text = str(keycode)
		input_found.emit(keycode)
