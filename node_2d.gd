extends Node2D

var str_test = "Josh"


# Called when the node enters the scene tree for the first time.
func _ready():
	var arr_str = str_test.split()
	print(arr_str)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
