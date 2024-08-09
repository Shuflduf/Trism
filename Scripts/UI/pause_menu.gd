extends Control

@onready var main_paused := $PAUSED
@onready var settings_menu := $Settings
@onready var controls := $Controls
@onready var sonic: CheckButton = $Settings/VBoxContainer/Sonic

@export_file("*.tscn") var main_menu : String

var can_pause := true

@onready var sliders := [%ARRSlider, %DASSlider, %DCDSlider, %SDFSlider]
@onready var spinboxes := [%ARRLineEdit, %DASLineEdit, %DCDLineEdit, %SDFLineEdit]

signal pause_state(pause_state : bool)

#signal modify_handling(setting, value)

func handle_pause(go_to_options := false) -> void:
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

func load_handling() -> void:
	#arr_num.value = Settings.arr
	#das_num.value = Settings.das
	#dcd_num.value = Settings.dcd
	#sdf_num.value = Settings.sdf
	sonic.button_pressed = Settings.sonic

func _ready() -> void:
	visible = false
	call_deferred("load_handling")

	for i: int in sliders.size():
		sliders[i].value_changed.connect(func(value: int) -> void:
			spinboxes[i] = value
			Settings.set(sliders[i].get_parent().name, value))

		spinboxes[i].value_changed.connect(func(value: int) -> void:
			sliders[i] = value)

func _on_open_settings_pressed() -> void:
	main_paused.visible = false
	settings_menu.visible = true

func _on_switch_to_controls_pressed() -> void:
	settings_menu.visible = false
	controls.visible = true

func _on_main_menu_pressed() -> void:
	handle_pause()
	can_pause = false
	get_parent().move_child(self, 0)
	SceneManager.transition_to(main_menu)
	await SceneManager.transitioned_out
	can_pause = true

func unpause_game() -> void:
	visible = false

func _on_rtx_toggled(toggled_on: bool) -> void:
	Settings.rtx_on = toggled_on

func _on_cinematic_toggled(toggled_on: bool) -> void:
	Settings.cinematic_mode = toggled_on

func _on_sonic_toggled(toggled_on: bool) -> void:
	Settings.sonic = toggled_on






