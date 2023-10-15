@tool @icon("res://addons/time-of-day/icons/Sky.svg")
class_name TOD_Manager extends Node

var editor_hint: bool:
	get: return Engine.is_editor_hint()

@export_group("Nodes")
@export
var sky_path: NodePath:
	get: return sky_path
	set(value):
		sky_path = value
		_sky = get_node_or_null(value)
		
		if _sky != null:
			_set_celestials_coords()

var _sun: TOD_Sun:
	get: return _sun
	set(value):
		_sun = value
		if _sun != null:
			_set_celestials_coords()

var _moon: TOD_Moon:
	get: return _moon
	set(value):
		_moon = value
		if _moon != null:
			_set_celestials_coords()

var _sky: TOD_Sky = null

# Date Time.
# ------------------------------------------------------------------------------
@export_group("DateTime")
signal timeline_changed(value)
signal day_changed(value)
signal month_changed(value)
signal year_changed(value)

@export var system_sync: bool = false
@export var total_cycle_in_minutes: float = 15.0

@export_range(0.0, 24.0)
var timeline: float = 7.0:
	get: return timeline
	set(value):
		timeline = value
		emit_signal(&"timeline_changed", timeline)
		if editor_hint:
			_set_celestials_coords()

@export_range(0, 31)
var day: int  = 12:
	get: return day
	set(value):
		day = value
		emit_signal(&"day_changed", day)
		if editor_hint:
			_set_celestials_coords()

@export_range(0, 31)
var month: int = 2:
	get: return month
	set(value):
		month = value
		emit_signal(&"month_changed", month)
		if editor_hint:
			_set_celestials_coords()

@export_range(-9999, 9999)
var year: int = 2022:
	get: return year
	set(value):
		year = value
		emit_signal(&"year_changed", year)
		if editor_hint:
			_set_celestials_coords()

var is_leap_year: bool:
	get: return TOD_DateTimeUtil.compute_leap_year(year)

var get_max_days_per_month: int:
	get:
		match month:
			1, 3, 5, 7, 8, 10, 12:
				return 31
			2:
				return 29 if is_leap_year else 28
		return 30

var time_cycle_duration: float:
	get: return total_cycle_in_minutes * 60.0

var is_begin_of_time: bool:
	get: return year == 1 && month == 1 && day == 1

var is_end_of_time: bool:
	get: return year == 9999 && month == 12 && day == 31

var _date_time_os: Dictionary

# ------------------------------------------------------------------------------

# Planetary
# ------------------------------------------------------------------------------
enum CelestialsCalculation{ SIMPLE = 0, REALISTIC }

@export_group("Planetary")
@export
var celestials_update_time: float = 0.0

@export_subgroup("Features")

@export_enum("Simple", "Realistic")
var celestials_calculations: int = CelestialsCalculation.REALISTIC:
	get: return celestials_calculations
	set(value):
		celestials_calculations = value
		if editor_hint:
			_set_celestials_coords()

@export
var compute_moon_coords: bool = true:
	get: return compute_moon_coords
	set(value):
		compute_moon_coords = value
		if editor_hint:
			_set_celestials_coords()

@export
var compute_deep_space_coords: bool = true:
	get: return compute_deep_space_coords
	set(value):
		compute_deep_space_coords = value
		if editor_hint:
			_set_celestials_coords()

@export_subgroup("Coords")
@export_range(-90.0, 90.0)
var latitude: float = 0.0:
	get: return latitude
	set(value):
		latitude = value
		if editor_hint:
			_set_celestials_coords()

@export_range(-180.0, 180.0)
var longitude: float = 0.0:
	get: return longitude
	set(value):
		longitude = value
		if editor_hint:
			_set_celestials_coords()

@export_range(-12.0, 12.0)
var utc: float = 0.0:
	get: return utc
	set(value):
		utc = value
		if editor_hint:
			_set_celestials_coords()

@export
var moon_coords_offset:= Vector2(0.0, 0.0):
	get: return moon_coords_offset
	set(value):
		moon_coords_offset = value
		if editor_hint:
			_set_celestials_coords()

var _celestials_update_timer: float = 0.0

var _get_latitude_rad: 
	get: return latitude * TOD_Math.DEG_TO_RAD

var _get_timeline_utc: float:
	get: return timeline - utc

var _get_time_scale: float:
	get: return (367.0 * year - (7.0 * (year + ((month + 9.0) / 12.0))) / 4.0 +\
		(275.0 * month) / 9.0 + day - 730530.0) + timeline / 24.0

var _get_oblecl: float:
	get: return (23.4393 - 2.563e-7 * _get_time_scale) * TOD_Math.DEG_TO_RAD

var _sun_coords:= Vector2.ZERO
var _moon_coords:= Vector2.ZERO
var _sun_distance: float
var _true_sun_longitude: float 
var _mean_sun_longitude: float
var _sideral_time: float
var _local_sideral_time: float

var _sun_orbital_elements:= TOD_OrbitalElements.new()
var _moon_orbital_elements:= TOD_OrbitalElements.new()

# ------------------------------------------------------------------------------

func _init() -> void:
	pass

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
	
	sky_path = sky_path
	system_sync = system_sync
	total_cycle_in_minutes = total_cycle_in_minutes
	timeline = timeline
	day = day
	month = month
	year = year
	
	celestials_update_time = celestials_update_time
	celestials_calculations = celestials_calculations
	compute_moon_coords = compute_moon_coords
	compute_deep_space_coords = compute_deep_space_coords
	
	latitude = latitude
	longitude = longitude
	utc = utc
	moon_coords_offset = moon_coords_offset

func _exit_tree() -> void:
	# Sun.
	if GlobalCelestials.sun_added.is_connected(_on_added_sun):
		GlobalCelestials.sun_added.disconnect(_on_added_sun)
	
	if GlobalCelestials.sun_removed.is_connected(_on_removed_sun):
		GlobalCelestials.sun_removed.disconnect(_on_removed_sun)
	
	# Moon.
	if GlobalCelestials.moon_added.is_connected(_on_added_moon):
		GlobalCelestials.moon_added.disconnect(_on_added_moon)
	
	if GlobalCelestials.moon_removed.is_connected(_on_removed_moon):
		GlobalCelestials.moon_removed.disconnect(_on_removed_moon)

func _on_added_sun() -> void:
	if(GlobalCelestials.get_sun_celestials().size() > 0):
		_sun = GlobalCelestials.get_sun_celestials()[0]

func _on_removed_sun() -> void:
	_sun = null

func _on_added_moon() -> void:
	if(GlobalCelestials.get_moon_celestials().size() > 0):
		_moon = GlobalCelestials.get_moon_celestials()[0]

func _on_removed_moon() -> void:
	_moon = null

func _process(delta: float) -> void:
	if editor_hint:
		return
	if !system_sync:
		_time_process(delta)
		_repeat_full_cucle()
		_check_cycle()
	else:
		_get_date_time_os()
	
	_celestials_update_timer += delta;
	if _celestials_update_timer > celestials_update_time:
		_set_celestials_coords()
		_celestials_update_timer = 0.0

func _time_process(p_delta) -> void:
	if time_cycle_duration != 0.0:
		timeline = timeline + p_delta / time_cycle_duration * 24.0
	
func _repeat_full_cucle():
	if is_end_of_time && timeline > 23.9999:
		year = 1; month = 1; day = 1
		timeline = 0
	if is_begin_of_time && timeline < 0.0:
		year = 9999; month = 12; day = 31
		timeline = 23.9999

func _check_cycle():
	if timeline > 23.9999:
		day = day + 1
		timeline = 0.0

	if timeline < 0.0000:
		day = day - 1
		timeline = 23.9999
	
	if day > get_max_days_per_month:
		month = month + 1
		day = 1

	if day < 1:
		month = month - 1
		day = 31
	
	if month > 12:
		year = year + 1
		month = 1
	
	if month < 1:
		year = year - 1
		month = 12

func _get_date_time_os():
	_date_time_os = Time.get_date_dict_from_system()
	set_time(_date_time_os.hour, _date_time_os.minute, _date_time_os.second)
	day = _date_time_os.day
	month = _date_time_os.month
	year = _date_time_os.year

func set_time(p_hour: int, p_minute: int, p_second: int) -> void:
	timeline = TOD_DateTimeUtil.hours_to_total_hours(p_hour, p_minute, p_second)

# ------------------------------------------------------------------------------

# Planetary.
# ------------------------------------------------------------------------------

# Simple Calculations.
func _compute_simple_sun_coords() -> void:
	var altitude:= (_get_timeline_utc + (TOD_Math.DEG_TO_RAD * longitude)) * 15 # (360/24)
	_sun_coords.y = (180.0 - altitude)
	_sun_coords.x = 90.0+latitude

func _compute_simple_moon_coords() -> void:
	_moon_coords.y = (180.0 - _sun_coords.y) + moon_coords_offset.y
	_moon_coords.x = (180.0 + _sun_coords.x) + moon_coords_offset.x

# Realistic Calculations.
func _compute_realistic_sun_coords() -> void:
	## Orbital Elements.
	_sun_orbital_elements.compute_orbital_elements(
		TOD_OrbitalElements.Celestial.SUN, _get_time_scale
	)
	_sun_orbital_elements.M = TOD_Math.rev(_sun_orbital_elements.M)
	
	# Mean anomaly in radians.
	var MRad: float = TOD_Math.DEG_TO_RAD * _sun_orbital_elements.M
	
	## Eccentric Anomaly
	var E: float = _sun_orbital_elements.M + TOD_Math.RAD_TO_DEG * _sun_orbital_elements.e *\
		sin(MRad) * (1 + _sun_orbital_elements.e * cos(MRad))
	
	var ERad: float = E * TOD_Math.DEG_TO_RAD
	
	## Rectangular coordinates.
	# Rectangular coordinates of the sun in the plane of the ecliptic.
	var xv: float = cos(ERad) - _sun_orbital_elements.e
	var yv: float = sin(ERad) * sqrt(1 - _sun_orbital_elements.e * _sun_orbital_elements.e)
	
	## Distance and true anomaly.
	# Convert to distance and true anomaly(r = radians, v = degrees).
	var r: float = sqrt(xv * xv + yv * yv)
	var v: float = TOD_Math.RAD_TO_DEG * atan2(yv, xv)
	_sun_distance = r
	
	## True longitude.
	var lonSun: float = v + _sun_orbital_elements.w
	lonSun = TOD_Math.rev(lonSun)
	
	var lonSunRad = TOD_Math.DEG_TO_RAD * lonSun
	_true_sun_longitude = lonSunRad
	
	## Ecliptic and ecuatorial coords.
	
	# Ecliptic rectangular coords.
	var xs: float = r * cos(lonSunRad)
	var ys: float = r * sin(lonSunRad)
	
	# Ecliptic rectangular coordinates rotate these to equatorial coordinates
	var obleclCos: float = cos(_get_oblecl)
	var obleclSin: float = sin(_get_oblecl)
	
	var xe: float = xs 
	var ye: float = ys * obleclCos - 0.0 * obleclSin
	var ze: float = ys * obleclSin + 0.0 * obleclCos
	
	## Ascencion and declination.
	var RA: float = TOD_Math.RAD_TO_DEG * atan2(ye, xe) / 15 # right ascension.
	var decl: float = atan2(ze, sqrt(xe * xe + ye * ye)) # declination
	
	# Mean longitude.
	var L: float = _sun_orbital_elements.w + _sun_orbital_elements.M
	L = TOD_Math.rev(L)
	
	_mean_sun_longitude = L
	
	## Sideral time and hour angle.
	var GMST0: float = ((L/15) + 12)
	_sideral_time = GMST0 + _get_timeline_utc + longitude / 15 # +15/15
	_local_sideral_time = TOD_Math.DEG_TO_RAD * _sideral_time * 15
	
	var HA: float = (_sideral_time - RA) * 15
	var HARAD: float = TOD_Math.DEG_TO_RAD * HA
	
	## Hour angle and declination in rectangular coords
	# HA and Decl in rectangular coords.
	var declCos: float = cos(decl)
	var x = cos(HARAD) * declCos # X Axis points to the celestial equator in the south.
	var y = sin(HARAD) * declCos # Y axis points to the horizon in the west.
	var z = sin(decl) # Z axis points to the north celestial pole.
	
	# Rotate the rectangualar coordinates system along of the Y axis.
	var sinLat: float = sin(latitude * TOD_Math.DEG_TO_RAD)
	var cosLat: float = cos(latitude * TOD_Math.DEG_TO_RAD)
	var xhor: float = x * sinLat - z * cosLat
	var yhor: float = y 
	var zhor: float = x * cosLat + z * sinLat
	
	## Azimuth and altitude.
	_sun_coords.x = atan2(yhor, xhor) + PI
	_sun_coords.y = (PI * 0.5) - asin(zhor) # atan2(zhor, sqrt(xhor * xhor + yhor * yhor))

func _compute_realistic_moon_coords() -> void:
	## Orbital Elements.
	_moon_orbital_elements.compute_orbital_elements(
		TOD_OrbitalElements.Celestial.MOON, _get_time_scale
	)
	_moon_orbital_elements.N = TOD_Math.rev(_moon_orbital_elements.N)
	_moon_orbital_elements.w = TOD_Math.rev(_moon_orbital_elements.w)
	_moon_orbital_elements.M = TOD_Math.rev(_moon_orbital_elements.M)
	
	var NRad: float = TOD_Math.DEG_TO_RAD * _moon_orbital_elements.N
	var IRad: float = TOD_Math.DEG_TO_RAD * _moon_orbital_elements.i
	var MRad: float = TOD_Math.DEG_TO_RAD * _moon_orbital_elements.M
	
	## Eccentric anomaly.
	var E: float = _moon_orbital_elements.M + TOD_Math.RAD_TO_DEG * _moon_orbital_elements.e * sin(MRad) *\
		(1 + _sun_orbital_elements.e * cos(MRad))
	
	var ERad = TOD_Math.DEG_TO_RAD * E
	
	## Rectangular coords and true anomaly
	# Rectangular coordinates of the sun in the plane of the ecliptic
	var xv: float = _moon_orbital_elements.a * (cos(ERad) - _moon_orbital_elements.e)
	var yv: float = _moon_orbital_elements.a * (sin(ERad) * sqrt(1 - _moon_orbital_elements.e * \
		_moon_orbital_elements.e)) * sin(ERad)
		
	# Convert to distance and true anomaly(r = radians, v = degrees)
	var r: float = sqrt(xv * xv + yv * yv)
	var v: float = TOD_Math.RAD_TO_DEG * atan2(yv, xv)
	v = TOD_Math.rev(v)
	
	var l: float = TOD_Math.DEG_TO_RAD * v + _moon_orbital_elements.w
	
	var cosL: float = cos(l)
	var sinL: float = sin(l)
	var cosNRad: float = cos(NRad)
	var sinNRad: float = sin(NRad)
	var cosIRad: float = cos(IRad)
	
	var xeclip: float = r * (cosNRad * cosL - sinNRad * sinL * cosIRad)
	var yeclip: float = r * (sinNRad * cosL + cosNRad * sinL * cosIRad)
	var zeclip: float = r * (sinL * sin(IRad))
	
	## Geocentric coords.
	# Geocentric position for the moon and Heliocentric position for the planets
	var lonecl: float = TOD_Math.RAD_TO_DEG * atan2(yeclip, xeclip)
	lonecl = TOD_Math.rev(lonecl)
	
	var latecl: float = TOD_Math.RAD_TO_DEG * atan2(zeclip, sqrt(xeclip * xeclip + yeclip * yeclip))
	
	# Get true sun longitude.
	var lonsun: float = _true_sun_longitude
	
	# Ecliptic longitude and latitude in radians
	var loneclRad: float = TOD_Math.DEG_TO_RAD * lonecl
	var lateclRad: float = TOD_Math.DEG_TO_RAD * latecl
	
	var nr: float = 1.0
	var xh: float = nr * cos(loneclRad) * cos(lateclRad)
	var yh: float = nr * sin(loneclRad) * cos(lateclRad)
	var zh: float = nr * sin(lateclRad)
	
	# Geocentric coords.
	var xs: float = 0.0
	var ys: float = 0.0
	
	# Convert the geocentric position to heliocentric position.
	var xg: float = xh + xs
	var yg: float = yh + ys
	var zg: float = zh
	
	## Ecuatorial coords.
	# Cobert xg, yg un equatorial coords.
	var obleclCos: float = cos(_get_oblecl)
	var obleclSin: float = sin(_get_oblecl)
	
	var xe: float = xg 
	var ye: float = yg * obleclCos - zg * obleclSin
	var ze: float = yg * obleclSin + zg * obleclCos
	
	# Right ascention.
	var RA: float = TOD_Math.RAD_TO_DEG * atan2(ye, xe)
	RA = TOD_Math.rev(RA)
	
	# Declination.
	var decl: float = TOD_Math.RAD_TO_DEG * atan2(ze, sqrt(xe * xe + ye * ye))
	var declRad: float = TOD_Math.DEG_TO_RAD * decl
	
	## Sideral time and hour angle.
	# Hour angle.
	var HA: float = ((_sideral_time * 15) - RA)
	HA = TOD_Math.rev(HA)
	var HARAD: float = TOD_Math.DEG_TO_RAD * HA
	
	# HA y Decl in rectangular coordinates.
	var declCos: float = cos(declRad)
	var xr: float = cos(HARAD) * declCos
	var yr: float = sin(HARAD) * declCos
	var zr: float = sin(declRad)
	
	# Rotate the rectangualar coordinates system along of the Y axis(radians).
	var sinLat: float = sin(_get_latitude_rad)
	var cosLat: float = cos(_get_latitude_rad)
	
	var xhor: float = xr * sinLat - zr * cosLat
	var yhor: float = yr 
	var zhor: float = xr * cosLat + zr * sinLat
	
	## Azimuth and altitude
	_moon_coords.x = atan2(yhor, xhor) + PI
	_moon_coords.y = (PI *0.5) - atan2(zhor, sqrt(xhor * xhor + yhor * yhor)) # Mathf.Asin(zhor)

func _set_celestials_coords() -> void:
	match celestials_calculations:
		CelestialsCalculation.SIMPLE:
			_compute_simple_sun_coords()
			if _sun != null:
				_sun.transform_type = TOD_Celestial.TransformType.ORBIT
				_sun.altitude = _sun_coords.y
				_sun.azimuth = _sun_coords.x
			
			if compute_moon_coords:
				_compute_simple_moon_coords()
				if _moon != null:
					_moon.transform_type = TOD_Celestial.TransformType.ORBIT
					_moon.altitude = _moon_coords.y
					_moon.azimuth = _moon_coords.x
			
			if compute_deep_space_coords:
				if _sky != null:
					var x = Quaternion.from_euler(
						Vector3((90 + latitude) * TOD_Math.DEG_TO_RAD, 0.0, 0.0)
					)
					var y = Quaternion.from_euler(
						Vector3(0.0, 0.0, _sun_coords.y * TOD_Math.DEG_TO_RAD)
					)
					if _sky.material != null:
						_sky.material.deep_space_quat = x*y
		
		CelestialsCalculation.REALISTIC:
			_compute_realistic_sun_coords()
			if _sun != null:
				_sun.transform_type = TOD_Celestial.TransformType.ORBIT
				_sun.altitude = _sun_coords.y * TOD_Math.RAD_TO_DEG
				_sun.azimuth = _sun_coords.x * TOD_Math.RAD_TO_DEG
			
			if compute_moon_coords:
				_compute_realistic_moon_coords()
				if _moon != null:
					_moon.transform_type = TOD_Celestial.TransformType.ORBIT
					_moon.altitude = _moon_coords.y * TOD_Math.RAD_TO_DEG
					_moon.azimuth = _moon_coords.x * TOD_Math.RAD_TO_DEG
			
			if compute_deep_space_coords:
				if _sky != null:
					
					var x = Quaternion.from_euler(
						Vector3( (90 + latitude) * TOD_Math.DEG_TO_RAD, 0.0, 0.0) 
					)
					var y = Quaternion.from_euler(
						Vector3(0.0, 0.0,  (180.0 - _local_sideral_time * TOD_Math.RAD_TO_DEG) * TOD_Math.DEG_TO_RAD)
					)
					if _sky.material != null:
						
						_sky.material.deep_space_quat = x * y

func _get_configuration_warnings():
	if _sun == null && _moon == null:
		return ["Celestials not found"]
	elif _sun == null:
		return ["Sun not found"]
	elif _moon == null:
		return ["Moon not found"]
	
	return []
