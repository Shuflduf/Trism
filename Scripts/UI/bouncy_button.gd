@tool
class_name BouncyButton
extends Button

const THEME := preload("res://Resources/button_ui.tres")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	theme = THEME
