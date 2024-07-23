extends Control

@onready var main_paused = $PAUSED
@onready var settings_menu = $Settings
@onready var controls = $Controls

@export_file("*.tscn") var main_menu : String

var can_pause := true

#region handling vars
@onready var arr_slider = %ARRSlider
@onready var arr_num = %ARRLineEdit
@onready var das_slider = %DASSlider
@onready var das_num = %DASLineEdit
@onready var dcd_slider = %DCDSlider
@onready var dcd_num = %DCDLineEdit
@onready var sdf_slider = %SDFSlider
@onready var sdf_num = %SDFLineEdit
#endregion

signal pause_state(pause_state : bool)

#signal modify_handling(setting, value)

func handle_pause(go_to_options := false):
	if not can_pause:
		return
	get_parent().move_child(self, get_parent().get_child_count() - 1)
	if not visible:
		visible = true
		pause_state.emit(true)
		
		if go_to_options:
			main_paused.visible = false
			settings_menu.visible = true
		return
	if controls.visible:
		controls.visible = false
		settings_menu.visible = true
		return
	if settings_menu.visible:
		settings_menu.visible = false
		main_paused.visible = true
		return
	if main_paused.visible:
		visible = false
		pause_state.emit(false)
		#get_parent().move_child(self, 0)
		return

func _ready():
	visible = false

func _on_open_settings_pressed():
	main_paused.visible = false
	settings_menu.visible = true
	
func _on_switch_to_controls_pressed():
	settings_menu.visible = false
	controls.visible = true
	
func _on_main_menu_pressed():
	handle_pause()
	can_pause = false
	get_parent().move_child(self, 0)
	SceneManager.transition_to(main_menu)
	await SceneManager.transitioned_out
	can_pause = true
	
func unpause_game():
	visible = false

func _on_rtx_toggled(toggled_on):
	Settings.rtx_on = toggled_on
	
func _on_cinematic_toggled(toggled_on):
	Settings.cinematic_mode = toggled_on

#region handling stuff
func _on_arr_slider_value_changed(value):
	Settings.arr = value
	arr_num.value = value
	#modify_handling.emit("ARR", value)

func _on_arr_line_edit_value_changed(value):
	arr_slider.value = value

func _on_das_slider_value_changed(value):
	Settings.das = value
	das_num.value = value
	#modify_handling.emit("DAS", value)

func _on_das_line_edit_value_changed(value):
	das_slider.value = value
	
func _on_dcd_slider_value_changed(value):
	Settings.dcd = value
	dcd_num.value = value
	#modify_handling.emit("DCD", value)

func _on_dcd_line_edit_value_changed(value):
	dcd_slider.value = value
	
func _on_sdf_slider_value_changed(value):
	Settings.sdf = value
	sdf_num.value = value
	#modify_handling.emit("SDF", value)

func _on_sdf_line_edit_value_changed(value):
	sdf_slider.value = value
#endregion

func _on_sonic_toggled(toggled_on):
	Settings.sonic = toggled_on






