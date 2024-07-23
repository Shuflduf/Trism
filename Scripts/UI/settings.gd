extends Node

signal settings_changed

var rtx_on := false:
	set(value):
		rtx_on = value
		settings_changed.emit()
	get:
		return rtx_on
var cinematic_mode := false:
	set(value):
		cinematic_mode = value
		settings_changed.emit()
	get:
		return cinematic_mode

# handling settings
var arr := 2
var das := 10
var dcd : int
var sdf := 6

var sonic := false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SceneManager.transitioned_out.connect(func() -> void:
		settings_changed.emit())


