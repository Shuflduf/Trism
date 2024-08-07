extends Node3D

@onready var sub_viewport: SubViewport = $SubViewport

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await screenshot()


func screenshot() -> void:
	await RenderingServer.frame_post_draw
	var img := sub_viewport.get_texture().get_image()
	img.save_png("user://thing.png")
	print("saved")

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("hard"):
		screenshot()
