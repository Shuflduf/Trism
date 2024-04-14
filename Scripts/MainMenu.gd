extends Control

@export_file("*.tscn") var next_scene: String
@onready var pause_menu = $PauseMenu

func _on_button_pressed():
	SceneManager.transition_to(next_scene)

func _input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			pause_menu.handle_pause(true)


func _on_options_pressed():
	pass # Replace with function body.
