@tool @icon("res://addons/time-of-day/icons/Sky.svg")
extends TOD_SkyMaterialBase
class_name TOD_StandardMaterial

const _SHADER:= preload(
	"res://addons/time-of-day/src/sky/shaders/tod_standard_sky.gdshader"
)
const _DEFAULT_ATM_DAY_GRADIENT:= preload(
	"res://addons/time-of-day/content/resources/atmosphere/default_day_tint.tres"
)
const _DEFAULT_BACKGROUND_TEXTURE:= preload(
	"res://addons/time-of-day/content/textures/third-party/textures/milky-way/Milkyway.jpg"
)
const _DEFAULT_STARS_FIELD_TEXTURE:= preload(
	"res://addons/time-of-day/content/textures/third-party/textures/milky-way/StarField.jpg"
)
const _DEFAULT_CLOUDS_NOISE:= preload(
	"res://addons/time-of-day/content/textures/third-party/noise.png"
)

@export_group("General Settings")
@export
var apply_debanding: bool = false:
	get: return apply_debanding
	set(value):
		apply_debanding = value
		RenderingServer.material_set_param(
			_material.get_rid(), &"tod_apply_debanding", apply_debanding
		)
		emit_changed()

@export
var exposure: float = 1.0:
	get: return exposure
	set(value):
		exposure = value
		RenderingServer.material_set_param(
			_material.get_rid(), &"tod_exposure", exposure
		)
		emit_changed()

@export_range(-1.0, 1.0)
var horizon_level: float = 0.0:
	get: return horizon_level
	set(value):
		horizon_level = value
		RenderingServer.material_set_param(
			_material.get_rid(), &"tod_horizon_level", horizon_level
		)
		emit_changed()

@export_group("Atmosphere", "atm_")
@export
var atm_wavelenghts:= Vector3(680.0, 550.0, 440.0):
	get: return atm_wavelenghts
	set(value):
		atm_wavelenghts = value
		_set_beta_ray()

@export_range(0.0, 1.0)
var atm_darkness: float = 0.1:
	get: return atm_darkness
	set(value):
		atm_darkness = value
		RenderingServer.material_set_param(
			_material.get_rid(), &"tod_atm_darkness", atm_darkness
		)
		emit_changed()

@export
var atm_sun_intensity: float = 15.0:
	get: return atm_sun_intensity
	set(value):
		atm_sun_intensity = value
		RenderingServer.material_set_param(
			_material.get_rid(), &"tod_atm_sunE", atm_sun_intensity
		)
		emit_changed()

@export
var atm_day_tint:= Color(0.596, 0.82, 0.996):
	get: return atm_day_tint
	set(value):
		atm_day_tint = value
		_set_atm_day_tint()
		emit_changed()

@export
var atm_day_gradient: Gradient:
	get: return atm_day_gradient
	set(value):
		atm_day_gradient = value
		if value != null:
			_disconnect_changed_atm_day_gradient()
			_connect_changed_atm_day_gradient()
		
		_set_atm_day_tint()
		emit_changed()

@export
var atm_night_tint:= Color(0.254902, 0.337255, 0.447059):
	get: return atm_night_tint
	set(value):
		atm_night_tint = value
		_set_atm_night_tint()
		emit_changed()

@export
var atm_rayleigh_level: float = 1.0:
	get: return atm_rayleigh_level
	set(value):
		atm_rayleigh_level = value
		RenderingServer.material_set_param(
			_material.get_rid(), &"tod_atm_rayleigh_level", atm_rayleigh_level
		)
		emit_changed()

@export
var atm_thickness: float = 1.0:
	get: return atm_thickness
	set(value):
		atm_thickness = value
		RenderingServer.material_set_param(
			_material.get_rid(), &"tod_atm_thickness", atm_thickness
		)
		emit_changed()

@export_subgroup("Mie", "atm_")
@export
var atm_mie: float = 0.07:
	get: return atm_mie
	set(value):
		atm_mie = value
		_set_beta_mie()
		emit_changed()

@export
var atm_turbidity: float = 0.001:
	get: return atm_turbidity
	set(value):
		atm_turbidity = value
		_set_beta_mie()
		emit_changed()
		

@export_subgroup("Ground", "atm_")
@export
var atm_ground_color:= Color(0.2, 0.333, 0.494): # Color(0.204, 0.345, 0.467):
	get: return atm_ground_color
	set(value):
		atm_ground_color = value
		RenderingServer.material_set_param(
			_material.get_rid(), &"tod_atm_ground_color", atm_ground_color * 5.0
		)
		emit_changed()

var get_atm_night_intensity: float = 1.0:
	get:
		var ret: float;
		if !enable_night_scattering:
			ret = clamp(-sun_direction.y+0.50, 0.0, 1.0)
		else:
			ret = clamp(moon_direction.y * atm_moon_phases_mul, 0.0, 1.0)
		
		return ret;


@export_group('Deep Space')
#var __deep_space_euler: Vector3
@export 
var deep_space_euler:= Vector3(-0.752, -2.56, 0.0):
	get: 
		return deep_space_euler
	set(value):
		deep_space_euler = value
		deep_space_quat = Basis.from_euler(
			deep_space_euler
		).get_rotation_quaternion()
		
		emit_changed()

var deep_space_quat:= Quaternion.IDENTITY:
	get: return deep_space_quat
	set(value):
		deep_space_quat = value
		_deep_space_basis = Basis(value)
		#__deep_space_euler = _deep_space_basis.get_euler()
		RenderingServer.material_set_param(
			_material.get_rid(), &"tod_deep_space_matrix", _deep_space_basis
		)
		emit_changed()

var _deep_space_basis:= Basis()

@export_subgroup('Background')
@export
var background_color:= Color(0.4039, 0.4039, 0.4039, 0.5607):
	get: return background_color
	set(value):
		background_color = value
		RenderingServer.material_set_param(
			_material.get_rid(), &"tod_background_color", background_color
		)
		emit_changed()


@export var use_custom_bg_texture: bool = false:
	get: return use_custom_bg_texture
	set(value):
		use_custom_bg_texture = value
		if value:
			background_texture = background_texture
		else:
			background_texture = _DEFAULT_BACKGROUND_TEXTURE

@export
var background_texture: Texture = null:
	get: return background_texture
	set(value):
		background_texture = value
		_material.set_shader_parameter(&"tod_background_texture", background_texture)
		emit_changed()

@export_subgroup('StarsField')
@export
var stars_field_color:= Color.WHITE:
	get: return stars_field_color
	set(value):
		stars_field_color = value
		RenderingServer.material_set_param(
			_material.get_rid(), &"tod_stars_field_color", stars_field_color
		)
		emit_changed()

@export
var stars_field_intensity: float = 1.0:
	get: return stars_field_intensity
	set(value):
		stars_field_intensity = value
		RenderingServer.material_set_param(
			_material.get_rid(), &"tod_stars_field_intensity", stars_field_intensity
		)
		emit_changed()

@export
var use_custom_stars_field_texture: bool = false:
	get: return use_custom_stars_field_texture
	set(value):
		use_custom_stars_field_texture = value
		if value:
			stars_field_texture = stars_field_texture
		else:
			stars_field_texture = _DEFAULT_STARS_FIELD_TEXTURE

@export
var stars_field_texture: Texture = null:
	get: return stars_field_texture
	set(value):
		stars_field_texture = value
		_material.set_shader_parameter(&"tod_stars_field_texture", stars_field_texture)
		emit_changed()

@export_range(0.0, 1.0)
var stars_scintillation: float = 0.75:
	get: return stars_scintillation
	set(value):
		stars_scintillation = value
		RenderingServer.material_set_param(
			_material.get_rid(), &"tod_stars_scintillation", stars_scintillation
		)
		emit_changed()

@export_range(0.0, 10.0)
var stars_scintillation_speed: float = 1.0:
	get: return stars_scintillation_speed
	set(value):
		stars_scintillation_speed = value
		RenderingServer.material_set_param(
			_material.get_rid(), &"tod_stars_scintillation_speed", stars_scintillation_speed
		)
		emit_changed()


@export_group('Clouds')
@export_subgroup('Noise')

@export
var use_custom_clouds_noise_tex: bool = false:
	get: return use_custom_clouds_noise_tex
	set(value):
		use_custom_clouds_noise_tex = value
		if value:
			clouds_noise_tex = clouds_noise_tex
		else:
			clouds_noise_tex = _DEFAULT_CLOUDS_NOISE

@export
var clouds_noise_tex: Texture = null:
	get: return clouds_noise_tex
	set(value):
		clouds_noise_tex = value
		_material.set_shader_parameter(
			&"tod_clouds_noise_tex", clouds_noise_tex
		)
		emit_changed()

@export
var clouds_noise_freq: float = 2.6:
	get: return clouds_noise_freq
	set(value):
		clouds_noise_freq = value
		RenderingServer.material_set_param(
			_material.get_rid(), &"tod_clouds_noise_freq", clouds_noise_freq
		)
		emit_changed()

@export_subgroup('Coords')
@export
var clouds_size: float = 1.0:
	get: return clouds_size
	set(value):
		clouds_size = value
		RenderingServer.material_set_param(
			_material.get_rid(), &"tod_clouds_size", clouds_size
		)
		emit_changed()

@export_range(-499.0, 499.0) 
var clouds_shell_offset: float = -470.0:
	get: return clouds_shell_offset
	set(value):
		clouds_shell_offset = value
		RenderingServer.material_set_param(
			_material.get_rid(), &"tod_clouds_shell_offset", clouds_shell_offset
		)
		emit_changed()

@export_subgroup('Density')

@export
var clouds_smooth: float = 0.085:
	get: return clouds_smooth
	set(value):
		clouds_smooth = value
		RenderingServer.material_set_param(
			_material.get_rid(), &"tod_clouds_smooth", clouds_smooth
		)
		emit_changed()

@export_range(0.0, 1.0)
var clouds_coverage: float = 0.55:
	get: return clouds_coverage
	set(value):
		clouds_coverage = value
		RenderingServer.material_set_param(
			_material.get_rid(), &"tod_clouds_coverage", clouds_coverage
		)
		emit_changed()

@export_range(0.0, 10.0)#4
var clouds_absorption: float = 1.9:
	get: return clouds_absorption
	set(value):
		clouds_absorption = value
		RenderingServer.material_set_param(
			_material.get_rid(), &"tod_clouds_absorption", clouds_absorption
		)
		emit_changed()

@export_range(0.0, 20.0)#2
var clouds_thickness: float = 4.0:
	get: return clouds_thickness
	set(value):
		clouds_thickness = value
		RenderingServer.material_set_param(
			_material.get_rid(), &"tod_clouds_thickness", clouds_thickness
		)
		emit_changed()

@export_subgroup('Color')
@export
var clouds_intensity: float = 5.0:
	get: return clouds_intensity
	set(value):
		clouds_intensity = value
		RenderingServer.material_set_param(
			_material.get_rid(), &"tod_clouds_intensity", clouds_intensity
		)
		emit_changed()

#@export_range(0.0, 1.0)
#var clouds_atmosphere_inject: float = 0.3:
	#get: return clouds_atmosphere_inject
	#set(value):
		#clouds_atmosphere_inject = value
		#RenderingServer.material_set_param(
			#_material.get_rid(), &"tod_clouds_atmosphere_inject", clouds_atmosphere_inject
		#)
		#emit_changed()

@export
var clouds_zenith_color:= Color(0.835, 0.906, 1.0):
	get: return clouds_zenith_color
	set(value):
		clouds_zenith_color = value
		_set_clouds_day_color()
		emit_changed()

@export
var clouds_horizon_color:= Color(1.0, 0.482, 0.0):
	get: return clouds_horizon_color
	set(value):
		clouds_horizon_color = value
		_set_clouds_day_color()
		emit_changed()

@export
var clouds_night_color:= Color(0.1803, 0.3019, 0.5058):
	get: return clouds_night_color
	set(value):
		clouds_night_color = value
		_set_clouds_night_color()
		emit_changed()

@export_subgroup('Offset')
@export
var clouds_offset:= Vector3(0.05, -0.05, 0.01):
	get: return clouds_offset
	set(value):
		clouds_offset = value
		RenderingServer.material_set_param(
			_material.get_rid(), &"tod_clouds_offset", clouds_offset
		)
		emit_changed()

@export
var clouds_offset_speed: float = 0.1:
	get: return clouds_offset_speed
	set(value):
		clouds_offset_speed = value
		RenderingServer.material_set_param(
			_material.get_rid(), &"tod_clouds_offset_speed", clouds_offset_speed
		)
		emit_changed()

func _on_init() -> void:
	_material.shader = _SHADER
	super()
	apply_debanding = apply_debanding
	exposure = exposure
	tonemap_level = tonemap_level
	horizon_level = horizon_level
	
	atm_wavelenghts = atm_wavelenghts
	atm_darkness = atm_darkness
	atm_sun_intensity = atm_sun_intensity
	#use_custom_day_tint = use_custom_day_tint
	atm_day_tint = atm_day_tint
	atm_day_gradient = atm_day_gradient
	atm_night_tint = atm_night_tint

	atm_rayleigh_level = atm_rayleigh_level
	atm_thickness = atm_thickness
	
	atm_mie = atm_mie
	atm_turbidity = atm_turbidity
	atm_ground_color = atm_ground_color
	
	deep_space_euler = deep_space_euler
	deep_space_quat = deep_space_quat
	
	background_color = background_color
	use_custom_bg_texture = use_custom_bg_texture
	background_texture = background_texture
	
	stars_field_color = stars_field_color
	stars_field_intensity = stars_field_intensity
	use_custom_stars_field_texture = use_custom_stars_field_texture
	stars_field_texture = stars_field_texture
	stars_scintillation = stars_scintillation
	stars_scintillation_speed = stars_scintillation_speed
	
	use_custom_clouds_noise_tex = use_custom_clouds_noise_tex
	clouds_noise_tex = clouds_noise_tex
	clouds_smooth = clouds_smooth
	clouds_noise_freq = clouds_noise_freq
	clouds_size = clouds_size
	clouds_shell_offset = clouds_shell_offset
	clouds_coverage = clouds_coverage
	
	clouds_intensity = clouds_intensity
	clouds_absorption = clouds_absorption
	#clouds_atmosphere_inject = clouds_atmosphere_inject
	clouds_thickness = clouds_thickness
	clouds_zenith_color = clouds_zenith_color
	clouds_horizon_color = clouds_horizon_color
	clouds_night_color = clouds_night_color
	
	clouds_offset = clouds_offset
	clouds_offset_speed = clouds_offset_speed

func material_is_valid() -> bool:
	return true;

func _set_beta_ray() -> void:
	var wls:= TOD_ATM_LIB.compute_wavelenghts(atm_wavelenghts, true)
	var br:= TOD_ATM_LIB.compute_beta_ray(wls)
	RenderingServer.material_set_param(
		_material.get_rid(), &"tod_atm_beta_ray", br
	)
	emit_changed()

func _set_beta_mie() -> void:
	var bm:= TOD_ATM_LIB.compute_beta_mie(atm_mie, atm_turbidity)
	RenderingServer.material_set_param(
		_material.get_rid(), &"tod_atm_beta_mie", bm
	)
	emit_changed()

func _set_atm_day_tint() -> void:
	RenderingServer.material_set_param(
		_material.get_rid(), &"tod_atm_tint",
			atm_day_gradient.sample(TOD_Util.interpolate_by_above(sun_direction.y))
				if atm_day_gradient != null else lerp(atm_day_tint, Color.WHITE, (1.0-get_sun_uMuS)+0.2)
	)

func _set_atm_night_tint() -> void:
	var tint:= atm_night_tint * get_atm_night_intensity
	RenderingServer.material_set_param(
		_material.get_rid(), &"tod_atm_night_tint", tint
	)
	atm_moon_mie_intensity = atm_moon_mie_intensity
	emit_changed()

func _set_sun_uMuS() -> void:
	RenderingServer.material_set_param(
		_material.get_rid(), &"tod_sun_uMuS", get_sun_uMuS
	)

func _on_sun_direction_changed() -> void:
	super()
	_set_sun_uMuS()
	_set_atm_day_tint()
	_set_atm_night_tint()
	
	_set_clouds_day_color()
	_set_clouds_night_color()

func _on_moon_direction_changed() -> void:
	_set_sun_uMuS()
	_set_atm_night_tint()
	
	_set_clouds_day_color()
	_set_clouds_night_color()

func _connect_changed_atm_day_gradient() -> void:
	if !atm_day_gradient.changed.is_connected(_on_changed_day_gradient):
		atm_day_gradient.changed.connect(_on_changed_day_gradient)

func _disconnect_changed_atm_day_gradient() -> void:
	if atm_day_gradient.changed.is_connected(_on_changed_day_gradient):
		atm_day_gradient.changed.disconnect(_on_changed_day_gradient)

func _on_changed_day_gradient() -> void:
	_set_atm_day_tint()

func _set_clouds_day_color() -> void:
	RenderingServer.material_set_param(
		_material.get_rid(), &"tod_clouds_zenith_color", clouds_zenith_color
	)
	
	RenderingServer.material_set_param(
		_material.get_rid(), &"tod_clouds_horizon_color", clouds_horizon_color
	)

func _set_clouds_night_color() -> void:
	var color:= clouds_night_color * get_atm_night_intensity
	RenderingServer.material_set_param(
		_material.get_rid(), &"tod_clouds_night_color", color
	)
