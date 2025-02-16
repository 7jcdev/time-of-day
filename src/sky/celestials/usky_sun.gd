# Universal Sky
# Description:
# - Sun celestial body.
# License:
# - J. Cuéllar 2025 MIT License
# - See: LICENSE File.
@tool @icon("res://addons/universal-sky/assets/icons/sun.svg")
extends USkyCelestial
class_name USkySun

func _on_init() -> void:
	super()
	# Default sun values
	body_color = Color(1, 0.7058, 0.4470)
	body_intensity = 2.0
	body_size = 0.005

func _on_enter_tree() -> void:
	super()
	_add_to_parent()

func _on_exit_tree() -> void:
	_remove_from_parent()

func _on_parented() -> void:
	super()
	_add_to_parent()

func _add_to_parent() -> void:
	if is_instance_valid(parent):
		if parent.has_method(&"add_sun"):
			parent.add_sun(self)

func _remove_from_parent() -> void:
	if is_instance_valid(parent):
		if parent.has_method(&"remove_sun"):
			parent.remove_sun(self)
