# Universal Sky
# Description:
# - Dinamic skydome.
# License:
# - J. Cuéllar 2025 MIT License
# - See: LICENSE File.
@tool @icon("res://addons/universal-sky/assets/icons/Sky.svg")
class_name USkyDome extends Node3D

#region Dome Settings
@export_group("Dome Settings")
@export
var dome_visible: bool = true:
	get: return dome_visible
	set(value):
		dome_visible = value
		_dome_drawer.set_visible(dome_visible)

@export_enum("Low", "Medium", "High")
var dome_mesh_quality: int = 0:
	get: return dome_mesh_quality
	set(value):
		dome_mesh_quality = value
		_changed_dome_mesh_quality(dome_mesh_quality)

@export_flags_3d_render
var dome_layers: int = 4:
	get:
		return dome_layers
	set(value):
		dome_layers = value
		_dome_drawer.set_layers(dome_layers)
#endregion

#region Material
@export_group("Resources")
@export
var material: USkyMaterialBase = null:
	get: return material
	set(value):
		material = value
		if is_instance_valid(material):
			if !material.material_is_valid():
				material = null
				push_warning(
					"{material} is abstract class, please add valid material"
					.format({"material": material})
				)
			else:
				_set_sky_material_to_dome(material.material)
#endregion

#region Drawer
var _dome_drawer:= USkyDomeDrawer.new()
var _dome_mesh:= SphereMesh.new()
var _dome_material:= ShaderMaterial.new()
#endregion

#region Celestials
@export_group("Celestials")
@export
var _suns: Array[USkySun]:
	get: return _suns
	set(value):
		_suns = value

@export
var _moons: Array[USkyMoon]:
	get: return _moons
	set(value):
		_moons = value
#endregion

#region Godot
func _init() -> void:
	_changed_dome_mesh_quality(dome_mesh_quality)

func _notification(what: int) -> void:
	match(what):
		NOTIFICATION_ENTER_TREE:
			_dome_drawer.draw(get_world_3d(), _dome_mesh, _dome_material)
			_initialize_dome_params()
		NOTIFICATION_EXIT_TREE:
			_dome_drawer.clear()
		NOTIFICATION_PREDELETE:
			_dome_drawer.clear()

func _validate_property(property: Dictionary) -> void:
	if property.name == "_suns" || property.name == "_moons":
		property.usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_READ_ONLY
#endregion

#region Setup
func _initialize_dome_params() -> void:
	dome_visible = dome_visible
	dome_layers = dome_layers

func _changed_dome_mesh_quality(p_quality: int) -> void:
	if not is_instance_valid(_dome_mesh):
		return
	match p_quality:
			0: 
				_dome_mesh.radial_segments = 16
				_dome_mesh.rings = 8
			1: 
				_dome_mesh.radial_segments = 32
				_dome_mesh.rings = 32
			2: 
				_dome_mesh.radial_segments = 32
				_dome_mesh.rings = 90

func _set_sky_material_to_dome(p_material: ShaderMaterial) -> void:
	_dome_material = p_material
#endregion

#region Suns
func add_sun(p_sun: USkySun) -> void:
	if(_suns.any(func(p):return p==p_sun)):
		return
	_suns.push_back(p_sun)
	var index = _suns.find(p_sun)
	_connect_sun_direction_changed(index)
	_connect_sun_value_changed(index)
	_connect_sun_mie_value_changed(index)

func remove_sun(p_sun: USkySun) -> void:
	var index = _suns.find(p_sun)
	_disconnect_sun_direction_changed(index)
	_disconnect_sun_value_changed(index)
	_disconnect_sun_mie_value_changed(index)
	_suns.erase(p_sun)

# Direction
func _connect_sun_direction_changed(p_index: int) -> void:
	if !_suns[p_index].direction_changed.is_connected(_on_suns_direction_changed):
		_suns[p_index].direction_changed.connect(_on_suns_direction_changed)

func _disconnect_sun_direction_changed(p_index: int) -> void:
	if _suns[p_index].direction_changed.is_connected(_on_suns_direction_changed):
		_suns[p_index].direction_changed.disconnect(_on_suns_direction_changed)

# Body
func _connect_sun_value_changed(p_index: int) -> void:
	if !_suns[p_index].value_changed.is_connected(_on_suns_value_changed):
		_suns[p_index].value_changed.connect(_on_suns_value_changed)

func _disconnect_sun_value_changed(p_index: int) -> void:
	if _suns[p_index].value_changed.is_connected(_on_suns_value_changed):
		_suns[p_index].value_changed.disconnect(_on_suns_value_changed)

# Mie
func _connect_sun_mie_value_changed(p_index: int) -> void:
	if !_suns[p_index].mie_value_changed.is_connected(_on_suns_mie_value_changed):
		_suns[p_index].mie_value_changed.connect(_on_suns_mie_value_changed)

func _disconnect_sun_mie_value_changed(p_index: int) -> void:
	if _suns[p_index].mie_value_changed.is_connected(_on_suns_mie_value_changed):
		_suns[p_index].mie_value_changed.disconnect(_on_suns_mie_value_changed)

func _on_suns_direction_changed() -> void:
	pass

func _on_suns_value_changed(p_type: int) -> void:
	pass

func _on_suns_mie_value_changed(p_type: int) -> void:
	pass

#endregion

#region Moons
func add_moon(p_moon: USkyMoon) -> void:
	if(_moons.any(func(p): return p == p_moon)):
		return
	_moons.push_back(p_moon)
	var index = _moons.find(p_moon)
	_connect_moon_direction_changed(index)
	_connect_moon_value_changed(index)
	_connect_moon_mie_value_changed(index)

func remove_moon(p_moon: USkyMoon) -> void:
	var index = _moons.find(p_moon)
	_disconnect_moon_direction_changed(index)
	_disconnect_moon_value_changed(index)
	_disconnect_moon_mie_value_changed(index)
	_moons.erase(p_moon)

func _connect_moon_direction_changed(p_index: int) -> void:
	if !_moons[p_index].direction_changed.is_connected(_on_moons_direction_changed):
		_moons[p_index].direction_changed.connect(_on_moons_direction_changed)

func _disconnect_moon_direction_changed(p_index: int) -> void:
	if _moons[p_index].direction_changed.is_connected(_on_moons_direction_changed):
		_moons[p_index].direction_changed.disconnect(_on_moons_direction_changed)

func _connect_moon_value_changed(p_index: int) -> void:
	if !_moons[p_index].value_changed.is_connected(_on_moons_value_changed):
		_moons[p_index].value_changed.connect(_on_moons_value_changed)

func _disconnect_moon_value_changed(p_index: int) -> void:
	if _moons[p_index].value_changed.is_connected(_on_moons_value_changed):
		_moons[p_index].value_changed.disconnect(_on_moons_value_changed)

func _connect_moon_mie_value_changed(p_index: int) -> void:
	if !_moons[p_index].mie_value_changed.is_connected(_on_moons_mie_value_changed):
		_moons[p_index].mie_value_changed.connect(_on_moons_mie_value_changed)

func _disconnect_moon_mie_value_changed(p_index: int) -> void:
	if _moons[p_index].mie_value_changed.is_connected(_on_moons_mie_value_changed):
		_moons[p_index].mie_value_changed.disconnect(_on_moons_mie_value_changed)

func _on_moons_direction_changed() -> void:
	pass

func _on_moons_value_changed(p_type: int) -> void:
	pass

func _on_moons_mie_value_changed(p_type: int) -> void:
	pass
#endregion
