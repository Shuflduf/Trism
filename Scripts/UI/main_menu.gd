extends Control

@export_file("*.tscn") var next_scene: String

func _on_button_pressed() -> void:
	get_parent().move_child(self, get_parent().get_child_count() - 1)
	SceneManager.transition_to(next_scene)

func _input(event: InputEvent) -> void:
	if !event is InputEventKey:
		return

	if event.is_action_pressed("pause"):
		PauseMenu.handle_pause()

func _on_options_pressed() -> void:
	PauseMenu.handle_pause(true)
