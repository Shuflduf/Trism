extends Node

signal settings_changed

var rtx_on := false:
	set(value):
		rtx_on = value
		settings_changed.emit()
	get:
		return rtx_on

# handling settings
var arr := 2
var das := 10
var dcd : int
var sdf := 6


# Called when the node enters the scene tree for the first time.
func _ready():
	SceneManager.transitioned_out.connect(func():
		settings_changed.emit())
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass
