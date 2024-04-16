extends Control

@export_file("*.tscn") var next_scene: String

func _on_button_pressed():
	get_parent().move_child(self, get_parent().get_child_count() - 1)
	SceneManager.transition_to(next_scene)

func _input(event):
	match event.get_class():
		"InputEventKey":
			if Input.is_action_just_pressed("pause"):
				PauseMenu.handle_pause()
				
func _on_options_pressed():
	PauseMenu.handle_pause(true)
