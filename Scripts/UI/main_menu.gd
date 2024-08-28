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

func _ready() -> void:
	var new_dir := Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	new_dir /= 30.0
	$Backround.material.set_shader_parameter("dir", new_dir)
