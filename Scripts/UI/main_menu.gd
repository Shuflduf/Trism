extends Control

@export_file("*.tscn") var next_scene: String

func _on_button_pressed() -> void:
	get_parent().move_child(self, get_parent().get_child_count() - 1)
	SceneManager.transition_to(next_scene)

func _input(event: InputEvent) -> void:
	match event.get_class():
		"InputEventKey":
			if Input.is_action_just_pressed("pause"):
				PauseMenu.handle_pause()

func _on_options_pressed() -> void:
	PauseMenu.handle_pause(true)
