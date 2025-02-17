# Universal Sky
# Description:
# - Standard sky material base.
# License:
# - J. Cuéllar 2025 MIT License
# - See: LICENSE File.
@tool
class_name USkyStandardMaterialBase extends USkyMaterialBase

func material_is_valid() -> bool:
	return false

func _init() -> void:
	super()
