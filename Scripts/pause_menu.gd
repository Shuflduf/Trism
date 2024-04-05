extends Control

@onready var paused = $PAUSED
@onready var settings = $Settings

signal toggle_rtx(on_off)

func pause_game():
	visible = true
	#paused.visible = true
	#settings.visible = false

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
