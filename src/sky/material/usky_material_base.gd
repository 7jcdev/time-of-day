# Universal Sky
# Description:
# - Sky material base.
# License:
# - J. Cuéllar 2025 MIT License
# - See: LICENSE File.
@tool
class_name USkyMaterialBase extends Resource

var _material:= ShaderMaterial.new()
var material: ShaderMaterial:
	get: return _material

var _refl_material:= ShaderMaterial.new()
var refl_material: ShaderMaterial:
	get: return _material

var _sun_directions: Array[Vector3]
var _moon_directions: Array[Vector3]

func _init() -> void:
	_material.render_priority = -128

func material_is_valid() -> bool:
	return false
