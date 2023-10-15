@tool
extends EditorPlugin

func _enter_tree() -> void:
	add_autoload_singleton("GlobalCelestials",
		"res://addons/time-of-day/src/sky/celestials/tod_global_celestials.gd")

func _exit_tree() -> void:
	remove_autoload_singleton("GlobalCelestials")
