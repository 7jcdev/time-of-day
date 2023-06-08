@tool @icon('res://addons/jc.time-of-day/icons/Sky.svg')
class_name TOD_Sky extends Node

@export
var material: TOD_SkyMaterial = null:
	get: return material
	set(value):
		material = value
		if not value.is_valid_material():
			material = null
		
		_set_sky_to_enviro()
		_set_sun()
		_set_moon()

@export_group('Nodes')
@export
var sun_path: NodePath = '':
	get: return sun_path
	set(value):
		sun_path = value
		_sun = get_node_or_null(sun_path)
		_set_sun()

@export
var moon_path: NodePath = '':
	get: return moon_path
	set(value):
		moon_path = value
		_moon = get_node_or_null(moon_path)
		_set_moon()

@export
var enviro_container: NodePath:
	get: return enviro_container
	set(value):
		enviro_container = value
		var container = get_node_or_null(value)
		if is_instance_of(container, Camera3D) || \
			is_instance_of(container, WorldEnvironment):
			_enviro = container.environment
		
		_set_sky_to_enviro()

# ------------------------------------------------------------------------------
var _enviro: Environment = null
var _sun: TOD_Sun = null
var _moon: TOD_Moon = null
# ------------------------------------------------------------------------------
var get_enviro: Environment:
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

# ------------------------------------------------------------------------------
func _enter_tree() -> void:
	material = material
	enviro_container = enviro_container
	
	sun_path = sun_path
	moon_path = moon_path
	

func _exit_tree() -> void:
	if _enviro != null:
		_enviro.sky.sky_material = null

# ------------------------------------------------------------------------------
func _set_sky_to_enviro() -> void:
	if _enviro == null:
		return
	_enviro.background_mode = Environment.BG_SKY
	if _enviro.sky == null:
		_enviro.sky = Sky.new()
	if material != null:
		_enviro.sky.sky_material = material.get_material
	else:
		_enviro.sky.sky_material = null
# ------------------------------------------------------------------------------
func _set_sun() -> void:
	_disconnect_sun_signals()
	_connect_sun_signals()
	_on_sun_direction_changed()
	
	for i in range(0, 3):
		_on_sun_value_changed(i)

func _connect_sun_signals() -> void:
	if _sun == null:
		return
	if !_sun.is_connected(TOD_Celestial.DIRECTION_CHANGED, _on_sun_direction_changed):
		_sun.connect(TOD_Celestial.DIRECTION_CHANGED, _on_sun_direction_changed)
			
	if !_sun.is_connected(TOD_Sun.VALUE_CHANGED, _on_sun_value_changed):
		_sun.connect(TOD_Sun.VALUE_CHANGED, _on_sun_value_changed)

func _disconnect_sun_signals() -> void:
	if _sun == null:
		return
	if _sun.is_connected(TOD_Celestial.DIRECTION_CHANGED, _on_sun_direction_changed):
		_sun.disconnect(TOD_Celestial.DIRECTION_CHANGED, _on_sun_direction_changed)
			
	if _sun.is_connected(TOD_Sun.VALUE_CHANGED, _on_sun_value_changed):
		_sun.disconnect(TOD_Sun.VALUE_CHANGED, _on_sun_value_changed)

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
# ------------------------------------------------------------------------------
func _set_moon() -> void:
	_disconnect_moon_signals()
	_connect_moon_signals()
	_on_moon_direction_changed()
	
	for i in range(0, 5):
		_on_moon_value_changed(i)

func _connect_moon_signals() -> void:
	if _moon == null:
		return
	if !_moon.is_connected(TOD_Celestial.DIRECTION_CHANGED, _on_moon_direction_changed):
		_moon.connect(TOD_Celestial.DIRECTION_CHANGED, _on_moon_direction_changed)
		
	if !_moon.is_connected(TOD_Moon.VALUE_CHANGED, _on_moon_value_changed):
		_moon.connect(TOD_Moon.VALUE_CHANGED, _on_moon_value_changed)

func _disconnect_moon_signals() -> void:
	if _moon == null:
		return
	if _moon.is_connected(TOD_Celestial.DIRECTION_CHANGED, _on_moon_direction_changed):
		_moon.disconnect(TOD_Celestial.DIRECTION_CHANGED, _on_moon_direction_changed)
			
	if _moon.is_connected(TOD_Moon.VALUE_CHANGED, _on_moon_value_changed):
		_moon.disconnect(TOD_Moon.VALUE_CHANGED, _on_moon_value_changed)

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
# ------------------------------------------------------------------------------
