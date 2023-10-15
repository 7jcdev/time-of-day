extends DirectionalLight3D
class_name TOD_Celestial 

enum TransformType{ ORBIT = 0, ROTATION }
enum MieValueType{ COLOR, INTENSITY, ANISOTROPY }

@export_group("Coords")
@export_enum("Orbit", "Rotation")
var transform_type: int = TransformType.ROTATION:
	get: return transform_type
	set(value):
		transform_type = value
		_update_params()
		notify_property_list_changed()

var altitude: float = 68.8916:
	get: return altitude
	set(value):
		altitude = value
		if transform_type == TransformType.ORBIT:
			_update_coords()

var azimuth: float = 21.9201:
	get: return azimuth
	set(value):
		azimuth = value
		if transform_type == TransformType.ORBIT:
			_update_coords()

# ------------------------------------------------------------------------------

@export_group("Mie")
@export_color_no_alpha
var mie_color:= Color.WHITE:
	get: return mie_color
	set(value):
		mie_color = value
		emit_signal(MIE_VALUE_CHANGED, MieValueType.COLOR)

@export
var mie_intensity: float = 1.0:
	get: return mie_intensity
	set(value):
		mie_intensity = value
		emit_signal(MIE_VALUE_CHANGED, MieValueType.INTENSITY)

@export_range(0.0, 0.9999)
var mie_anisotropy: float = 0.85:
	get: return mie_anisotropy
	set(value):
		mie_anisotropy = value
		emit_signal(MIE_VALUE_CHANGED, MieValueType.ANISOTROPY)

@export_group("Lighting")
@export
var lighting_color:= Color(0.984314, 0.843137, 0.788235):
	get: return lighting_color
	set(value):
		lighting_color = value
		_update_light_color()

@export
var lighting_color_gradient: Gradient = null:
	get: return lighting_color_gradient
	set(value):
		lighting_color_gradient = value
		
		if value == null:
			_disconnect_light_gradient_changed()
		_connect_light_gradient_changed()
		_update_light_color()

@export
var lighting_energy: float = 1.0:
	get: return lighting_energy
	set(value):
		lighting_energy = value
		_update_light_energy()

@export
var lighting_energy_curve: Curve = null:
	get: return lighting_energy_curve
	set(value):
		lighting_energy_curve = value
		if value == null:
			_disconnect_light_curve_changed()
		_connect_light_curve_changed()
		_update_light_energy()

# ------------------------------------------------------------------------------

const DIRECTION_CHANGED = "direction_changed"
const VALUE_CHANGED = "value_changed"
const MIE_VALUE_CHANGED = "mie_value_changed"
var _tmp_transform:= Transform3D()

signal direction_changed
signal value_changed(type)
signal mie_value_changed(type)

var direction: Vector3:
	get: return -(transform.basis * Vector3.FORWARD)

func _notification(what:int) -> void:
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		#if transform_type != TransformType.ORBIT:
		_update_params()
	if what == NOTIFICATION_ENTER_TREE:
		_on_enter_tree()

func _on_enter_tree() -> void:
	_initialize_params()

func _initialize_params() -> void:
	transform_type = transform_type
	altitude = altitude
	azimuth = azimuth
	lighting_color = lighting_color
	lighting_color_gradient = lighting_color_gradient
	lighting_energy = lighting_energy
	lighting_energy_curve = lighting_energy_curve
	mie_color = mie_color
	mie_intensity = mie_intensity
	mie_anisotropy = mie_anisotropy

func _update_coords() -> void:
	var azmR: float = azimuth * TOD_Math.DEG_TO_RAD
	var altR: float = altitude * TOD_Math.DEG_TO_RAD
	
	var finish_set_sun_pos:= false
	if !finish_set_sun_pos:
		_tmp_transform.origin = TOD_Math.to_orbit(altR, azmR)
		finish_set_sun_pos = true

	if finish_set_sun_pos:
		_tmp_transform = _tmp_transform.looking_at(Vector3.ZERO, Vector3.LEFT)
	
#	#if light_energy > 0.0:
	transform = _tmp_transform
	
	#if transform_type == TransformType.ORBIT:
	#	_update_params()

func _update_params():
	_update_light_color()
	_update_light_energy()
	emit_signal(DIRECTION_CHANGED)

func _update_light_color() -> void:
	if lighting_color_gradient != null:
		light_color = lighting_color_gradient.sample(
			TOD_Util.interpolate_by_above(direction.y)
		)
	else:
		light_color = lighting_color

func _update_light_energy() -> void:
	light_energy = _get_light_energy()

func _get_light_energy() -> float:
	if lighting_energy_curve != null:
		return lighting_energy_curve.sample(TOD_Util.interpolate_by_above(direction.y))
	return lerp(0.0, lighting_energy, clamp(direction.y, 0.0, 1.0))

func _connect_light_gradient_changed() -> void:
	if lighting_color_gradient == null:
		return
	if !lighting_color_gradient.changed.is_connected(_on_light_gradient_changed):
		lighting_color_gradient.changed.connect(_on_light_gradient_changed)

func _disconnect_light_gradient_changed() -> void:
	if lighting_color_gradient == null:
		return
	if lighting_color_gradient.changed.is_connected(_on_light_gradient_changed):
		lighting_color_gradient.changed.disconnect(_on_light_gradient_changed)

func _connect_light_curve_changed() -> void:
	if lighting_energy_curve == null:
		return
	if !lighting_energy_curve.changed.is_connected(_on_light_curve_changed):
		lighting_energy_curve.changed.connect(_on_light_curve_changed)

func _disconnect_light_curve_changed() -> void:
	if lighting_energy_curve == null:
		return
	if lighting_energy_curve.changed.is_connected(_on_light_curve_changed):
		lighting_energy_curve.changed.disconnect(_on_light_curve_changed)

func _on_light_gradient_changed() -> void:
	_update_light_color()

func _on_light_curve_changed() -> void:
	_update_light_energy()

func _get_property_list():
	var ret:= Array()
	ret.push_back({name = "Coords", type=TYPE_NIL, usage=PROPERTY_USAGE_GROUP})
	if transform_type == TransformType.ORBIT:
		ret.push_back({name = "altitude", type=TYPE_FLOAT, hint=PROPERTY_HINT_RANGE, hint_string="-180.0, 180.0"})
		ret.push_back({name = "azimuth", type=TYPE_FLOAT, hint=PROPERTY_HINT_RANGE, hint_string="-180.0, 180.0"})
	
	return ret
