@tool
class_name TOD_SkyMaterial extends Resource

var _material:= ShaderMaterial.new()
var get_material: ShaderMaterial:
	get: return _material

var sun_direction:= Vector3.ZERO:
	get: return sun_direction
	set(value):
		sun_direction = value
		RenderingServer.material_set_param(
			_material.get_rid(), TOD_SkyConst.SUN_DIRECTION, sun_direction
		)
		_on_sun_direction_changed()
		emit_changed()

var sun_disk_color:= Color.WHITE:
	get: return sun_disk_color
	set(value):
		sun_disk_color = value
		RenderingServer.material_set_param(
			_material.get_rid(), TOD_SkyConst.SUN_DISK_COLOR, sun_disk_color
		)
		emit_changed()

var sun_disk_intensity: float = 1.0:
	get: return sun_disk_intensity
	set(value):
		sun_disk_intensity = value
		RenderingServer.material_set_param(
			_material.get_rid(), TOD_SkyConst.SUN_DISK_INTENSITY, sun_disk_intensity
		)
		emit_changed()

var sun_disk_size: float = 0.03:
	get: return sun_disk_size
	set(value):
		sun_disk_size = value
		RenderingServer.material_set_param(
			_material.get_rid(), TOD_SkyConst.SUN_DISK_SIZE, sun_disk_size
		)
		emit_changed()

#-------------------------------------------------------------------------------

var moon_direction:= Vector3.ZERO:
	get: return moon_direction
	set(value):
		moon_direction = value
		RenderingServer.material_set_param(
			_material.get_rid(), TOD_SkyConst.MOON_DIRECTION, moon_direction
		)
		_on_moon_direction_changed()
		emit_changed()

var moon_color:= Color.WHITE:
	get: return moon_color
	set(value):
		moon_color = value
		RenderingServer.material_set_param(
			_material.get_rid(), TOD_SkyConst.MOON_COLOR, moon_color
		)
		emit_changed()

var moon_intensity: float = 1.0:
	get: return moon_intensity
	set(value):
		moon_intensity = value
		RenderingServer.material_set_param(
			_material.get_rid(), TOD_SkyConst.MOON_INTENSITY, moon_intensity
		)
		emit_changed()

var moon_size: float = 0.01:
	get: return moon_size
	set(value):
		moon_size = value
		RenderingServer.material_set_param(
			_material.get_rid(), TOD_SkyConst.MOON_SIZE, moon_size
		)
		emit_changed()

var moon_texture: Texture = null:
	get: return moon_texture
	set(value):
		moon_texture = value
		_material.set_shader_parameter(TOD_SkyConst.MOON_TEXTURE, moon_texture)
		emit_changed()

var moon_matrix: Basis:
	get: return moon_matrix
	set(value):
		moon_matrix = value
		RenderingServer.material_set_param(
			_material.get_rid(), TOD_SkyConst.MOON_MATRIX, moon_matrix
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

var atm_moon_phases_mul: float = 1.0:
	get: 
		var ret: float = 1.0
		if enable_night_scattering:
			ret = atm_moon_phases_mul
		return ret
	set(value):
		atm_moon_phases_mul = value

var get_sun_uMuS: float:
	get: return 0.015 + (atan(max(sun_direction.y, - 0.1975) * tan(1.386)) * 0.9090 + 0.74) * 0.5 * (0.96875);

func _init() -> void:
	_on_init()

func _on_init() -> void:
	enable_night_scattering = enable_night_scattering
	atm_moon_phases_mul = atm_moon_phases_mul

func is_valid_material() -> bool:
	return false
	
func _on_sun_direction_changed() -> void:
	pass

func _on_moon_direction_changed() -> void:
	pass
