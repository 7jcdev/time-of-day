@tool
extends Resource
class_name TOD_SkyMaterialBase

var _material:= ShaderMaterial.new()
var material: ShaderMaterial:
	get: return _material

# Sun
var sun_direction:= Vector3.ZERO:
	get: return sun_direction
	set(value):
		sun_direction = value
		RenderingServer.material_set_param(
			_material.get_rid(), TOD_CelestialsConst.SUN_DIRECTION, sun_direction
		)
		_on_sun_direction_changed()
		emit_changed()

var sun_disk_color:= Color.WHITE:
	get: return sun_disk_color
	set(value):
		sun_disk_color = value
		RenderingServer.material_set_param(
			_material.get_rid(), TOD_CelestialsConst.SUN_DISK_COLOR, sun_disk_color
		)
		emit_changed()

var sun_disk_intensity: float = 1.0:
	get: return sun_disk_intensity
	set(value):
		sun_disk_intensity = value
		RenderingServer.material_set_param(
			_material.get_rid(), TOD_CelestialsConst.SUN_DISK_INTENSITY, sun_disk_intensity
		)
		emit_changed()

var sun_disk_size: float = 0.03:
	get: return sun_disk_size
	set(value):
		sun_disk_size = value
		RenderingServer.material_set_param(
			_material.get_rid(), TOD_CelestialsConst.SUN_DISK_SIZE, sun_disk_size
		)
		emit_changed()

# Moon
var moon_direction:= Vector3.ZERO:
	get: return moon_direction
	set(value):
		moon_direction = value
		RenderingServer.material_set_param(
			_material.get_rid(), TOD_CelestialsConst.MOON_DIRECTION, moon_direction
		)
		_on_moon_direction_changed()
		emit_changed()

var moon_color:= Color.WHITE:
	get: return moon_color
	set(value):
		moon_color = value
		RenderingServer.material_set_param(
			_material.get_rid(), TOD_CelestialsConst.MOON_COLOR, moon_color
		)
		emit_changed()

var moon_intensity: float = 1.0:
	get: return moon_intensity
	set(value):
		moon_intensity = value
		RenderingServer.material_set_param(
			_material.get_rid(), TOD_CelestialsConst.MOON_INTENSITY, moon_intensity
		)
		emit_changed()

var moon_size: float = 0.01:
	get: return moon_size
	set(value):
		moon_size = value
		RenderingServer.material_set_param(
			_material.get_rid(), TOD_CelestialsConst.MOON_SIZE, moon_size
		)
		emit_changed()

var moon_texture: Texture = null:
	get: return moon_texture
	set(value):
		moon_texture = value
		_material.set_shader_parameter(TOD_CelestialsConst.MOON_TEXTURE, moon_texture)
		emit_changed()

var moon_matrix: Basis:
	get: return moon_matrix
	set(value):
		moon_matrix = value
		RenderingServer.material_set_param(
			_material.get_rid(), TOD_CelestialsConst.MOON_MATRIX, moon_matrix
		)
		emit_changed()

@export_group('Scattering Settings')
@export
var enable_night_scattering: bool = false:
	get: return enable_night_scattering
	set(value):
		enable_night_scattering = value
		_on_sun_direction_changed()
		_on_moon_direction_changed()
		emit_changed()

var atm_sun_mie_tint:= Color.WHITE:
	get: return atm_sun_mie_tint
	set(value):
		atm_sun_mie_tint = value
		RenderingServer.material_set_param(
			_material.get_rid(), &'tod_atm_sun_mie_tint', atm_sun_mie_tint
		)
		emit_changed()

var atm_sun_mie_intensity: float = 1.0:
	get: return atm_sun_mie_intensity
	set(value):
		atm_sun_mie_intensity = value
		RenderingServer.material_set_param(
			_material.get_rid(), &'tod_atm_sun_mie_intensity', atm_sun_mie_intensity
		)
		emit_changed()

var atm_sun_mie_anisotropy: float = 0.85:
	get: return atm_sun_mie_anisotropy
	set(value):
		atm_sun_mie_anisotropy = clamp(value, 0.0, 0.999)
		var partial:= TOD_ATM_LIB.get_partial_mie_phase(atm_sun_mie_anisotropy)
		RenderingServer.material_set_param(
			_material.get_rid(), &'tod_atm_sun_partial_mie_phase', partial
		)
		emit_changed()

var atm_moon_mie_tint:= Color(0.62, 0.82, 1.0):
	get: return atm_moon_mie_tint
	set(value):
		atm_moon_mie_tint = value
		RenderingServer.material_set_param(
			_material.get_rid(), &'tod_atm_moon_mie_tint', atm_moon_mie_tint
		)
		emit_changed()

var atm_moon_mie_intensity: float = 1.0:
	get: return atm_moon_mie_intensity
	set(value):
		atm_moon_mie_intensity = value
		RenderingServer.material_set_param(
			_material.get_rid(), &'tod_atm_moon_mie_intensity', 
				(atm_moon_mie_intensity * 0.001) * atm_moon_phases_mul
		)
		emit_changed()

var atm_moon_mie_anisotropy: float = 0.8:
	get: return atm_moon_mie_anisotropy
	set(value):
		atm_moon_mie_anisotropy = clamp(value, 0.0, 0.999)
		var partial:= TOD_ATM_LIB.get_partial_mie_phase(atm_moon_mie_anisotropy)
		RenderingServer.material_set_param(
			_material.get_rid(), &'tod_atm_moon_partial_mie_phase', partial
		)
		emit_changed()

var atm_moon_phases_mul: float = 1.0:
	get: 
		var ret: float = 1.0
		if enable_night_scattering:
			ret = atm_moon_phases_mul
		return ret
	set(value):
		atm_moon_phases_mul = value

var get_sun_uMuS: float:
	get: return 0.015 + (atan(max(sun_direction.y, - 0.1975) * tan(1.386))
		* 0.9090 + 0.74) * 0.5 * (0.96875);

#@export_range(0.0, 1.0)
var tonemap_level: float = 0.0:
	get: return tonemap_level
	set(value):
		tonemap_level = value
		RenderingServer.material_set_param(
			_material.get_rid(), &"tod_tonemap_level", tonemap_level
		)
		emit_changed()

func _init() -> void:
	_on_init()

func _on_init() -> void:
	enable_night_scattering = enable_night_scattering
	atm_moon_phases_mul = atm_moon_phases_mul

func _on_sun_direction_changed() -> void:
	pass

func _on_moon_direction_changed() -> void:
	pass

func material_is_valid() -> bool:
	return false
