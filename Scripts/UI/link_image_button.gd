class_name LinkImageButton
extends TextureButton

@export var url : String

func _pressed() -> void:
	OS.shell_open(url)

func _ready() -> void:

	tooltip_text += url
