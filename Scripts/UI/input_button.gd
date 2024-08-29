class_name InputButton
extends Button



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
		text = get_input_text(keycode)
		input_found.emit(keycode)

func get_input_text(keycode: String) -> String:
	var arrows := ["Left", "Right", "Down", "Up"]
	var new_text := ""
	if str(keycode) in arrows:
		new_text = keycode + " Arrow"
	else:
		new_text = str(keycode)
	return new_text
