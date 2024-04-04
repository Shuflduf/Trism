extends Control

@export_file("*.tscn") var next_scene: String

func _on_button_pressed():
	SceneManager.transition_to(next_scene)
