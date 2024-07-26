@icon("res://Assets/Editor/component.png")

class_name BaseComponent
extends Node

var parent: BaseGame:
	get:
		return get_parent()
