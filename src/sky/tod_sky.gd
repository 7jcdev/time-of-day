@tool @icon("res://addons/time-of-day/icons/Sky.svg")
extends Node
class_name TOD_Sky

@export
var material: TOD_SkyMaterialBase:
	get: return material
	set(value):
		material = value
		if value != null && !value.material_is_valid():
			material = null
			push_warning(
				"{value} is abstract class, please add valid material"
				.format({"value":value})
			)
		_set_sky_to_enviro()
		_on_added_sun()
		_on_added_moon()
		_connect_enviro_changed()

@export
var enviro_container: NodePath:
	get: return enviro_container
	set(value):
		enviro_container = value
		
		if enviro_container.is_empty():
			_disconnect_enviro_changed()
			if _enviro.sky != null:
				_enviro.sky.sky_material = null
			_enviro = null
			print("no enviro")
		else:
			var container = get_node_or_null(value)
			if is_instance_of(container, Camera3D) || \
				is_instance_of(container, WorldEnvironment):
					_enviro = container.environment
			
			_connect_enviro_changed()
			_set_sky_to_enviro()
			_on_added_sun()
			_on_added_moon()

var _enviro: Environment = null
var enviro: Environment:
	get: return _enviro

var check_sun_ready: bool:
	get:
		if material == null:
			return false
		if _sun == null:
			return false
		return true

var check_moon_ready: bool:
	get:
		if material == null:
			return false
		if _moon == null:
			return false
		return true

var get_moon_phases_mul: float:
	get: return _moon.get_phases_mul if _moon != null else 1.0

var _sun: TOD_Sun = null:
	get: return _sun
	set(value):
		_sun = value
		if value != null:
			_connect_sun_signals()

var _moon: TOD_Moon = null:
	get: return _moon
	set(value):
		_moon = value
		if value != null:
			_connect_moon_signals()

func _enter_tree() -> void:
	# Sun.
	if !GlobalCelestials.sun_added.is_connected(_on_added_sun):
		GlobalCelestials.sun_added.connect(_on_added_sun)
	
	if !GlobalCelestials.sun_removed.is_connected(_on_removed_sun):
		GlobalCelestials.sun_removed.connect(_on_removed_sun)
	
	_on_added_sun()
	
	# Moon.
	if !GlobalCelestials.moon_added.is_connected(_on_added_moon):
		GlobalCelestials.moon_added.connect(_on_added_moon)
	
	if !GlobalCelestials.moon_removed.is_connected(_on_removed_sun):
		GlobalCelestials.moon_removed.connect(_on_removed_moon)
	
	_on_added_moon()
	
	material = material
	enviro_container = enviro_container

func _exit_tree() -> void:
	# Sun.
	if GlobalCelestials.sun_added.is_connected(_on_added_sun):
		GlobalCelestials.sun_added.disconnect(_on_added_sun)
	
	if GlobalCelestials.sun_removed.is_connected(_on_removed_sun):
		GlobalCelestials.sun_removed.disconnect(_on_removed_sun)
	
	if (GlobalCelestials.get_sun_celestials().size() > 0):
		_disconnect_sun_signals()
	
	# Moon.
	if GlobalCelestials.moon_added.is_connected(_on_added_moon):
		GlobalCelestials.moon_added.disconnect(_on_added_moon)
	
	if GlobalCelestials.moon_removed.is_connected(_on_removed_moon):
		GlobalCelestials.moon_removed.disconnect(_on_removed_moon)
	
	if (GlobalCelestials.get_moon_celestials().size() > 0):
		_disconnect_moon_signals()
	
	if _enviro != null:
		_enviro.sky.sky_material = null
		_disconnect_enviro_changed()

func _connect_sun_signals() -> void:
	if !_sun.direction_changed.is_connected(_on_sun_direction_changed):
		_sun.direction_changed.connect(_on_sun_direction_changed)
	
	if !_sun.value_changed.is_connected(_on_sun_value_changed):
		_sun.value_changed.connect(_on_sun_value_changed)
	
	if !_sun.mie_value_changed.is_connected(_on_sun_mie_value_changed):
		_sun.mie_value_changed.connect(_on_sun_mie_value_changed)

func _disconnect_sun_signals() -> void:
	if _sun.direction_changed.is_connected(_on_sun_direction_changed):
		_sun.direction_changed.disconnect(_on_sun_direction_changed)
	
	if _sun.value_changed.is_connected(_on_sun_value_changed):
		_sun.value_changed.disconnect(_on_sun_value_changed)
	
	if _sun.mie_value_changed.is_connected(_on_sun_mie_value_changed):
		_sun.mie_value_changed.disconnect(_on_sun_mie_value_changed)

func _connect_moon_signals() -> void:
	if !_moon.direction_changed.is_connected(_on_moon_direction_changed):
		_moon.direction_changed.connect(_on_moon_direction_changed)
	
	if !_moon.value_changed.is_connected(_on_moon_value_changed):
		_moon.value_changed.connect(_on_moon_value_changed)
	
	if !_moon.mie_value_changed.is_connected(_on_moon_mie_value_changed):
		_moon.mie_value_changed.connect(_on_moon_mie_value_changed)

func _disconnect_moon_signals() -> void:
	if _moon.direction_changed.is_connected(_on_moon_direction_changed):
		_moon.direction_changed.disconnect(_on_moon_direction_changed)
	
	if _moon.value_changed.is_connected(_on_moon_value_changed):
		_moon.value_changed.disconnect(_on_moon_value_changed)
	
	if _moon.mie_value_changed.is_connected(_on_moon_mie_value_changed):
		_moon.mie_value_changed.disconnect(_on_moon_mie_value_changed)

func _on_added_sun() -> void:
	if(GlobalCelestials.get_sun_celestials().size() > 0):
		_sun = GlobalCelestials.get_sun_celestials()[0]
		for i in range(0, 3):
			_on_sun_value_changed(i)
			_on_sun_mie_value_changed(i)
		_on_sun_direction_changed()

func _on_removed_sun() -> void:
	if (GlobalCelestials.get_sun_celestials().size() > 0):
		_disconnect_sun_signals()
	else:
		_sun = null

func _on_added_moon() -> void:
	if(GlobalCelestials.get_moon_celestials().size() > 0):
		_moon = GlobalCelestials.get_moon_celestials()[0]
		for i in range(0, 4):
			_on_moon_value_changed(i)
		
		for i in range(0, 3):
			_on_moon_mie_value_changed(i)
		_on_moon_direction_changed()

func _on_removed_moon() -> void:
	if (GlobalCelestials.get_moon_celestials().size() > 0):
		_disconnect_moon_signals()
	else:
		_moon = null

func _on_sun_direction_changed() -> void:
	if !check_sun_ready:
		return
	material.sun_direction = _sun.direction
	material.atm_moon_phases_mul = get_moon_phases_mul

func _on_sun_value_changed(p_type: int) -> void:
	if !check_sun_ready:
		return
	if p_type == TOD_Sun.SunValueType.COLOR:
		material.sun_disk_color = _sun.disk_color
	if p_type == TOD_Sun.SunValueType.INTENSITY:
		material.sun_disk_intensity = _sun.disk_intensity
	if p_type == TOD_Sun.SunValueType.SIZE:
		material.sun_disk_size = _sun.disk_size

func _on_sun_mie_value_changed(p_type: int) -> void:
	if !check_sun_ready:
		return
	if p_type == TOD_Sun.MieValueType.COLOR:
		material.atm_sun_mie_tint = _sun.mie_color
	if p_type == TOD_Sun.MieValueType.INTENSITY:
		material.atm_sun_mie_intensity = _sun.mie_intensity
	if p_type == TOD_Sun.MieValueType.ANISOTROPY:
		material.atm_sun_mie_anisotropy = _sun.mie_anisotropy

func _on_moon_direction_changed() -> void:
	if !check_moon_ready:
		return
	material.moon_direction = _moon.direction
	material.moon_matrix = _moon.get_clamped_matrix
	material.atm_moon_phases_mul = get_moon_phases_mul

func _on_moon_value_changed(p_type: int) -> void:
	if !check_moon_ready:
		return
	if p_type == TOD_Moon.MoonValueType.COLOR:
		material.moon_color = _moon.color
	if p_type == TOD_Moon.MoonValueType.INTENSITY:
		material.moon_intensity = _moon.intensity
	if p_type == TOD_Moon.MoonValueType.SIZE:
		material.moon_size = _moon.size
	if p_type == TOD_Moon.MoonValueType.TEXTURE:
		material.moon_texture = _moon.texture

func _on_moon_mie_value_changed(p_type: int) -> void:
	if !check_moon_ready:
		return
	if p_type == TOD_Moon.MieValueType.COLOR:
		material.atm_moon_mie_tint = _moon.mie_color
	if p_type == TOD_Moon.MieValueType.INTENSITY:
		material.atm_moon_mie_intensity = _moon.mie_intensity
	if p_type == TOD_Moon.MieValueType.ANISOTROPY:
		material.atm_moon_mie_anisotropy = _moon.mie_anisotropy

func _set_sky_to_enviro() -> void:
	if _enviro == null:
		_disconnect_enviro_changed()
		return
	
	_enviro.background_mode = Environment.BG_SKY
	if _enviro.sky == null:
		_enviro.sky = Sky.new()
		_enviro.sky.process_mode = Sky.PROCESS_MODE_REALTIME
		_enviro.sky.radiance_size = Sky.RADIANCE_SIZE_256 # NOTE: Radiance size supported by realtime.
	if material != null:
		_enviro.sky.sky_material = material.material
		_on_enviro_changed()
	else:
		_enviro.sky.sky_material = null

func _connect_enviro_changed():
	if enviro == null:
		return
	
	if !enviro.property_list_changed.is_connected(_on_enviro_changed):
		enviro.property_list_changed.connect(_on_enviro_changed)
	
func _disconnect_enviro_changed():
	if enviro == null:
		return
	if enviro.property_list_changed.is_connected(_on_enviro_changed):
		enviro.property_list_changed.disconnect(_on_enviro_changed)

func _on_enviro_changed():
	if material == null:
		return
	if enviro.tonemap_mode == enviro.TONE_MAPPER_LINEAR:
		material.tonemap_level = 1.0
	else:
		material.tonemap_level = 0.0

func _get_configuration_warnings():
	if _sun == null && _moon == null:
		return ["Celestials not found"]
	elif _sun == null:
		return ["Sun not found"]
	elif _moon == null:
		return ["Moon not found"]
	if material == null:
		return ["Sky Material Not Found"]
	if enviro_container.is_empty():
		return ["Eviro container Not Found"]
	
	return []
