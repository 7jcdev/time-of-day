@tool @icon("res://addons/time-of-day/icons/moon.svg")
extends TOD_Celestial
class_name TOD_Moon

# Resources.
const _SUN_MOON_CURVE_FADE:= preload(
	"res://addons/time-of-day/content/resources/SunMoonLightFade.tres"
)
const _DEFAULT_MOON_TEXTURE:= preload(
	"res://addons/time-of-day/content/textures/third-party/textures/moon-map/MoonMap.png"
)

enum MoonValueType{ COLOR = 0, INTENSITY = 1, SIZE = 2, TEXTURE = 3 }

@export_group("Graphics")
@export 
var color:= Color(1.0, 1.0, 1.0, 1.0):
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

@export_group("Light Source")
@export
var enable_moon_phases: bool = false:
	get: return enable_moon_phases
	set(value):
		enable_moon_phases = value
		_update_light_energy()

var _sun: TOD_Sun = null:
	get: return _sun
	set(value):
		_sun = value
		if value != null:
			_connect_sun_signal()

var get_phases_mul: float:
	get: 
		if _sun != null:
			return clamp(-_sun.direction.dot(direction) + 0.50, 0.0, 1.0)
		
		return 1.0

var get_clamped_matrix: Basis:
	get: return Basis(
		-(basis * Vector3.FORWARD),
		-(basis * Vector3.UP),
		-(basis * Vector3.RIGHT)
	).transposed()

func _init() -> void:
	lighting_color = Color(0.54, 0.7, 0.9)
	lighting_energy = 0.3
	
	mie_color = Color(0.165, 0.533, 1)
	mie_intensity = 0.5

func _on_enter_tree() -> void:
	GlobalCelestials.add_moon(self)
	
	if !GlobalCelestials.sun_added.is_connected(_on_added_sun):
		GlobalCelestials.sun_added.connect(_on_added_sun)
	
	if !GlobalCelestials.sun_removed.is_connected(_on_removed_sun):
		GlobalCelestials.sun_removed.connect(_on_removed_sun)
	
	_on_added_sun()
	super()

func _exit_tree() -> void:
	if GlobalCelestials.sun_added.is_connected(_on_added_sun):
		GlobalCelestials.sun_added.disconnect(_on_added_sun)
	
	if GlobalCelestials.sun_removed.is_connected(_on_removed_sun):
		GlobalCelestials.sun_removed.disconnect(_on_removed_sun)
	
	if (GlobalCelestials.get_sun_celestials().size() > 0):
		_disconnect_sun_signal()
	
	GlobalCelestials.remove_moon(self)

func _on_added_sun() -> void:
	if(GlobalCelestials.get_sun_celestials().size() > 0):
		_sun = GlobalCelestials.get_sun_celestials()[0]

func _on_removed_sun() -> void:
	if (GlobalCelestials.get_sun_celestials().size() > 0):
		_disconnect_sun_signal()
	else:
		_sun = null

func _connect_sun_signal() -> void:
	if !_sun.direction_changed.is_connected(_on_sun_direction_changed):
		_sun.direction_changed.connect(_on_sun_direction_changed)

func _disconnect_sun_signal() -> void:
	if _sun.direction_changed.is_connected(_on_sun_direction_changed):
		_sun.direction_changed.disconnect(_on_sun_direction_changed)

func _on_sun_direction_changed() -> void:
	_update_light_energy()

func _initialize_params() -> void:
	super()
	color = color
	size = size
	intensity = intensity
	use_custom_texture = use_custom_texture
	texture = texture

func _get_light_energy() -> float:
	var energy = super()
	if enable_moon_phases:
		energy *= get_phases_mul
	
	if _sun != null:
		var fade: float = (1.0 - _sun.direction.y) - 0.5
		return energy * _SUN_MOON_CURVE_FADE.sample_baked(fade)
	
	return energy
