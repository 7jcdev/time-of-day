@tool @icon('res://addons/jc.time-of-day/icons/moon.svg')
class_name TOD_Moon extends TOD_Celestial
const _SUN_MOON_CURVE_FADE:= preload(
	'res://addons/jc.time-of-day/content/resources/SunMoonLightFade.tres'
)
const _DEFAULT_MOON_TEXTURE:= preload(
	'res://addons/jc.time-of-day/content/graphics/third-party/textures/moon-map/MoonMap.png'
)

enum MoonValueType{ COLOR = 0, INTENSITY = 1, SIZE = 2, TEXTURE = 3 }
const VALUE_CHANGED:= &'value_changed'
signal value_changed(type)

@export_group('Graphics')
@export 
var color:= Color(1.0, 1.0, 1.0, 0.5):
	get: return color
	set(value):
		color = value
		emit_signal(VALUE_CHANGED, MoonValueType.COLOR)

@export
var intensity: float = 1.0:
	get: return intensity
	set(value):
		intensity = value
		emit_signal(VALUE_CHANGED, MoonValueType.INTENSITY)

@export
var size: float = 0.02:
	get: return size
	set(value):
		size = value
		emit_signal(VALUE_CHANGED, MoonValueType.SIZE)

@export
var use_custom_texture: bool = false:
	get: return use_custom_texture
	set(value):
		use_custom_texture = value
		if value:
			texture = texture
		else:
			texture = _DEFAULT_MOON_TEXTURE

@export
var texture: Texture = null:
	get: return texture
	set(value):
		texture = value
		emit_signal(VALUE_CHANGED, MoonValueType.TEXTURE)

@export_group('Light Source')
@export
var enable_moon_phases: bool = false:
	get: return enable_moon_phases
	set(value):
		enable_moon_phases = value
		_update_light_energy()

@export
var sun_path: NodePath:
	get: return sun_path
	set(value):
		sun_path = value
		#if sun_path != ^'':
		_sun = get_node_or_null(sun_path) as TOD_Sun
		
		if _sun != null:
			_disconnect_signals()
			_connect_signals()

var _sun: TOD_Sun = null

var get_phases_mul: float:
	get: 
		if _sun != null:
			return TOD_Math.saturate(-_sun.direction.dot(direction) + 0.50)
		
		return 1.0

var get_clamped_matrix: Basis:
	get: return Basis(
		-(basis * Vector3.FORWARD),
		-(basis * Vector3.UP),
		-(basis * Vector3.RIGHT)
	).transposed()

var parent: TOD_Sky = null
func _initialize_params() -> void:
	super()
	sun_path = sun_path
	color = color
	size = size
	intensity = intensity
	use_custom_texture = use_custom_texture
	texture = texture

func _connect_signals() -> void:
	if not _sun.is_connected(DIRECTION_CHANGED, _on_changed_sun_direction):
		_sun.connect(DIRECTION_CHANGED, _on_changed_sun_direction)

func _disconnect_signals() -> void:
	if _sun.is_connected(DIRECTION_CHANGED, _on_changed_sun_direction):
		_sun.disconnect(DIRECTION_CHANGED, _on_changed_sun_direction)

func _on_changed_sun_direction() -> void:
	_update_light_energy()

func _update_light_energy() -> void:
	var energy = TOD_Math.lerp_f(0.0, lighting_energy, TOD_Math.saturate(direction.y))
	if enable_moon_phases:
		energy *= get_phases_mul
	
	if _sun != null:
		var fade: float = (1.0 - _sun.direction.y) + 0.5
		light_energy = energy * _SUN_MOON_CURVE_FADE.sample_baked(fade)
	else:
		light_energy = energy

# ------------------------------------------------------------------------------
