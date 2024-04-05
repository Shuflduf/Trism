extends Control

@onready var paused = $PAUSED
@onready var settings = $Settings

signal unpause

func pause_game():
	print("show pause")
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
		print("UNPAUSE")
		unpause_game()

func unpause_game():
	print("hide pause")
	visible = false
	unpause.emit()
