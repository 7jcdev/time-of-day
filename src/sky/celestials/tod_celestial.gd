class_name TOD_Celestial extends DirectionalLight3D

enum TransformType{ORBIT = 0, ROTATION}

@export_group('Coords')
@export_enum('Orbit', 'Rotation')
var transform_type: int = TransformType.ROTATION:
	get: return transform_type
	set(value):
		transform_type = value
		_update_params()
		notify_property_list_changed()

#@export_range(-180.0, 180.0)
var altitude: float = 68.8916:
	get: return altitude
	set(value):
		altitude = value
		
		if transform_type == TransformType.ORBIT:
			_update_coords()

#@export_range(-180.0, 180.0)
var azimuth: float = 21.9201:
	get: return azimuth
	set(value):
		azimuth = value
		if transform_type == TransformType.ORBIT:
			_update_coords()
# ------------------------------------------------------------------------------

@export_group('Lighting')
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
		_update_light_color()

@export
var lighting_energy: float = 2.0:
	get: return lighting_energy
	set(value):
		lighting_energy = value
		_update_light_energy()

@export
var lighting_energy_curve: Curve = null:
	get: return lighting_energy_curve
	set(value):
		lighting_energy_curve = value
		_update_light_energy()

# ------------------------------------------------------------------------------

var direction: Vector3:
	get: return -(transform.basis * Vector3.FORWARD)

var _tmp_transform:= Transform3D()

const DIRECTION_CHANGED:= &'direction_changed'
signal direction_changed()

func _notification(what:int) -> void:
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		if transform_type != TransformType.ORBIT:
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

# ------------------------------------------------------------------------------

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
	
	if transform_type == TransformType.ORBIT:
		_update_params()

func _update_params() -> void:
	_update_light_color()
	_update_light_energy()
	emit_signal(DIRECTION_CHANGED)

# ------------------------------------------------------------------------------

func _update_light_color() -> void:
	if lighting_color_gradient != null:
		light_color = lighting_color_gradient.sample(
			TOD_Util.interpolate_by_above(direction.y)
		)
	else:
		light_color = lighting_color

func _update_light_energy() -> void:
	if lighting_energy_curve != null:
		light_energy = lighting_energy_curve.sample(
			TOD_Util.interpolate_by_above(direction.y)
		)
	else:
		light_energy = TOD_Math.lerp_f(
			0.0, lighting_energy, TOD_Math.saturate(direction.y)
		)

func _get_property_list():
	var ret:= Array()
	ret.push_back({name = "Coords", type=TYPE_NIL, usage=PROPERTY_USAGE_GROUP})
	if transform_type == TransformType.ORBIT:
		ret.push_back({name = "altitude", type=TYPE_FLOAT, hint=PROPERTY_HINT_RANGE, hint_string="-180.0, 180.0"})
		ret.push_back({name = "azimuth", type=TYPE_FLOAT, hint=PROPERTY_HINT_RANGE, hint_string="-180.0, 180.0"})
	
	return ret
