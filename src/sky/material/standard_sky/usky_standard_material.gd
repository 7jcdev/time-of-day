# Universal Sky
# Description:
# - Standard sky material.
# License:
# - J. Cuéllar 2025 MIT License
# - See: LICENSE File.
@tool
class_name USkyStandandMaterial extends USkyStandardMaterialBase

func material_is_valid() -> bool:
	return true

func _init() -> void:
	super()
