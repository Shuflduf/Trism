extends Node

@export var keybind_resource : PlayerKeybindResource


func _on_tab_container_tab_changed(tab):
	match tab:
		0:
			switch_keybind_presets(keybind_resource.arrow_keys)
		1:
			switch_keybind_presets(keybind_resource.wasd_keys)

func switch_keybind_presets(preset: Array):
	for i in range(preset.size()):
		var event_key = InputEventKey.new()
		# Use the mapping to convert the string to a keycode
		var keycode = preset[i]
		if keycode:
			event_key.keycode = keycode
		else:
			print("Keycode for ", preset[i], " not found in mapping.")
		InputMap.action_erase_events(keybind_resource.input_keys[i])
		InputMap.action_add_event(keybind_resource.input_keys[i], event_key)

