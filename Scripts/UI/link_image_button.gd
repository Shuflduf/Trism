class_name LinkImageButton
extends TextureButton

@export var url : String

func _pressed() -> void:
	OS.shell_open(url)
