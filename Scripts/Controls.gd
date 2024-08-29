extends Node

@export var keybind_resource : PlayerKeybindResource

func _ready() -> void:

	_on_tab_container_tab_changed(get_child(0).current_tab)


func _on_tab_container_tab_changed(tab: int) -> void:
	match tab:
		2:
			switch_keybind_presets(keybind_resource.custom_keys)
		1:
			switch_keybind_presets(keybind_resource.arrow_keys)
		0:
			switch_keybind_presets(keybind_resource.wasd_keys)

	$"../Settings".save_settings()

func switch_keybind_presets(preset: Array) -> void:
	for i in range(preset.size()):
		var event_key := InputEventKey.new()
		var keycodes: Key = preset[i]
		if keycodes:
			event_key.keycode = keycodes
		else:
			print("Keycode for ", preset[i], " not found in mapping.")
		InputMap.action_erase_events(keybind_resource.input_keys[i])
		InputMap.action_add_event(keybind_resource.input_keys[i], event_key)


func _on_custom_updated_keybinds(keys: Array) -> void:
	FileAccess.open("user://trism.keybinds", FileAccess.WRITE).store_var(keys)
	#print(FileAccess.open("user://trism.keybinds", FileAccess.READ).get_var())
	keybind_resource.custom_keys = keys
	switch_keybind_presets(keybind_resource.custom_keys)
