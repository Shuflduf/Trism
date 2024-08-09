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
var dcd := 1
var sdf := 6

var sonic := false


func return_save_dict() -> Dictionary:
	return {
	"arr" : arr,
	"das" : das,
	"dcd" : dcd,
	"sdf" : sdf,
	"sonic" : sonic,
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_settings()
	save_settings()
	SceneManager.transitioned_out.connect(func() -> void:
		settings_changed.emit())


func save_settings() -> void:
	var save_file := FileAccess.open("user://trism.settings", FileAccess.WRITE)
	var data := JSON.stringify(return_save_dict())
	save_file.store_line(data)


func load_settings() -> void:
	var save_file := FileAccess.open("user://trism.settings", FileAccess.READ)
	var json_string := save_file.get_line()

	var json := JSON.new()

	var parse_result := json.parse(json_string)
	if not parse_result == OK:
		print("JSON Parse Error: ", json.get_error_message()\
				, " in ", json_string, " at line ", json.get_error_line())

	var node_data: Dictionary = json.get_data()

	for i: String in node_data.keys():
		set(i, node_data[i])
