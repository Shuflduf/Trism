extends Control

@onready var paused = $PAUSED
@onready var settings = $Settings

@onready var arr_slider = $Settings/CenterContainer/VBoxContainer/ARR/ARRSlider
@onready var arr_num = $Settings/CenterContainer/VBoxContainer/ARR/ARRLineEdit

@onready var das_slider = $Settings/CenterContainer/VBoxContainer/DAS/DASSlider
@onready var das_num = $Settings/CenterContainer/VBoxContainer/DAS/DASLineEdit

@onready var sdf_slider = $Settings/CenterContainer/VBoxContainer/SDF/SDFSlider
@onready var sdf_num = $Settings/CenterContainer/VBoxContainer/SDF/SDFLineEdit

signal toggle_rtx(on_off)

signal modify_handling(setting, value)

func pause_game():
	visible = true

func _ready():
	visible = false

func _on_open_settings_pressed():
	paused.visible = false
	settings.visible = true

func _input(event):
	if event.is_action_pressed("pause") and settings.visible:
		paused.visible = true
		settings.visible = false
	elif event.is_action_pressed("pause") and paused.visible:
		unpause_game()

func unpause_game():
	visible = false

func _on_rtx_toggled(toggled_on):
	toggle_rtx.emit(toggled_on)

func _on_arr_slider_value_changed(value):
	arr_num.value = value
	modify_handling.emit("ARR", value)

func _on_arr_line_edit_value_changed(value):
	arr_slider.value = value

func _on_das_slider_value_changed(value):
	das_num.value = value
	modify_handling.emit("DAS", value)

func _on_das_line_edit_value_changed(value):
	das_slider.value = value

func _on_sdf_slider_value_changed(value):
	sdf_num.value = value
	modify_handling.emit("SDF", value)

func _on_sdf_line_edit_value_changed(value):
	sdf_slider.value = value
