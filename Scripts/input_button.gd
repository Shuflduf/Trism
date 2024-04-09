class_name InputButton
extends Button

var looking_for_input
var saved_input

func cancel_look(button):
	looking_for_input = false
	print(button)

func _pressed():
	looking_for_input = true

func _input(event):
	if looking_for_input and event is InputEventKey:
		#var keycode = event.get("key_label")
		var keycode = OS.get_keycode_string(event.key_label)
		looking_for_input = false
		saved_input = keycode
		text = str(saved_input)
		
