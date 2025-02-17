# Universal Sky
# Description:
# - Sky material base.
# License:
# - J. Cuéllar 2025 MIT License
# - See: LICENSE File.
@tool
class_name USkyMaterialBase extends Resource

var _material:= ShaderMaterial.new()
var material: ShaderMaterial:
	get: return _material

var _refl_material:= ShaderMaterial.new()
var refl_material: ShaderMaterial:
	get: return _refl_material

var _suns_data:= USkyCelestialsData.new()
var suns_data: USkyCelestialsData:
	get: return _suns_data

var _moons_data:= USkyMoonData.new()
var moons_data: USkyMoonData:
	get: return _moons_data

func _init() -> void:
	_material.render_priority = -128
	_setup_data_array_size()

func material_is_valid() -> bool:
	return false

#region Setup
func _setup_data_array_size() -> void:
	_setup_suns_params_array_size(1)
	_setup_moons_params_array_size(1)

func _setup_suns_params_array_size(p_size: int) -> void:
	for i in range(p_size):
		_suns_data.direction.push_back(Vector3())
		_suns_data.size.push_back(0)
		_suns_data.color.push_back(Color())
		_suns_data.intensity.push_back(0)
		_suns_data.mie_color.push_back(Color())
		_suns_data.mie_intensity.push_back(0)
		_suns_data.mie_anisotropy.push_back(0)

func _setup_moons_params_array_size(p_size: int) -> void:
	for i in range(p_size):
		_moons_data.direction.push_back(Vector3())
		_moons_data.size.push_back(0)
		_moons_data.color.push_back(Color())
		_moons_data.intensity.push_back(0)
		_moons_data.texture.push_back(Texture2D.new())
		_moons_data.mie_color.push_back(Color())
		_moons_data.mie_intensity.push_back(0)
		_moons_data.mie_anisotropy.push_back(0)
		_moons_data.matrix.push_back(Basis())
#endregion

#region Update Suns
func update_suns_direction() -> void:
	for p in len(_suns_data.direction):
		print("SUN" + str(p) + " DIRECTION: " + str(_suns_data.direction[p]))
	
	RenderingServer.material_set_param(
		material.get_rid(), &"sun_direction", _suns_data.direction
	)
	
	RenderingServer.material_set_param(
		refl_material.get_rid(), &"sun_direction", _suns_data.direction
	)
	emit_changed()

func update_suns_color() -> void:
	for p in len(_suns_data.color):
		print("SUN" + str(p) + " COLOR: " + str(_suns_data.color[p]))
	
	RenderingServer.material_set_param(
		material.get_rid(), &"sun_color", _suns_data.color
	)
	
	RenderingServer.material_set_param(
		refl_material.get_rid(), &"sun_color", _suns_data.color
	)
	emit_changed()

func update_suns_intensity() -> void:
	for p in len(_suns_data.intensity):
		print("SUN" + str(p) + " INTENSITY: " + str(_suns_data.intensity[p]))
	
	RenderingServer.material_set_param(
		material.get_rid(), &"sun_intensity", _suns_data.intensity
	)
	
	RenderingServer.material_set_param(
		refl_material.get_rid(), &"sun_intensity", _suns_data.intensity
	)
	emit_changed()

func update_suns_size() -> void:
	for p in len(_suns_data.size):
		print("SUN" + str(p) + " SIZE: " + str(_suns_data.size[p]))
	
	RenderingServer.material_set_param(
		material.get_rid(), &"sun_size", _suns_data.size
	)
	
	RenderingServer.material_set_param(
		refl_material.get_rid(), &"sun_size", _suns_data.size
	)
	emit_changed()

func update_suns_mie_color() -> void:
	for p in len(_suns_data.mie_color):
		print("SUN" + str(p) + " MIE COLOR: " + str(_suns_data.mie_color[p]))
	
	RenderingServer.material_set_param(
		material.get_rid(), &"sun_mie_color", _suns_data.mie_color
	)
	
	RenderingServer.material_set_param(
		refl_material.get_rid(), &"sun_mie_color", _suns_data.mie_color
	)
	emit_changed()

func update_suns_mie_intensity() -> void:
	for p in len(_suns_data.mie_intensity):
		print("SUN" + str(p) + " MIE INTENSITY: " + str(_suns_data.mie_intensity[p]))
	
	RenderingServer.material_set_param(
		material.get_rid(), &"sun_mie_intensity", _suns_data.mie_intensity
	)
	
	RenderingServer.material_set_param(
		refl_material.get_rid(), &"sun_mie_intensity", _suns_data.mie_intensity
	)
	emit_changed()

func update_suns_mie_anisotropy() -> void:
	for p in len(_suns_data.mie_anisotropy):
		print("SUN" + str(p) + " MIE ANISOTROPY: " + str(_suns_data.mie_anisotropy[p]))
	
	RenderingServer.material_set_param(
		material.get_rid(), &"sun_mie_anisotropy", _suns_data.mie_anisotropy
	)
	
	RenderingServer.material_set_param(
		refl_material.get_rid(), &"sun_mie_anisotropy", _suns_data.mie_anisotropy
	)
	emit_changed()
#endregion

#region Update Moons
func update_moons_direction() -> void:
	for p in len(_moons_data.direction):
		print("MOON" + str(p) + " DIRECTION: " + str(_moons_data.direction[p]))
	
	RenderingServer.material_set_param(
		material.get_rid(), &"moon_direction", _moons_data.direction
	)
	
	RenderingServer.material_set_param(
		refl_material.get_rid(), &"moon_direction", _moons_data.direction
	)
	emit_changed()

func update_moons_matrix() -> void:
	for p in len(_moons_data.matrix):
		print("MOON" + str(p) + " MATRIX: " + str(_moons_data.matrix[p]))
	
	RenderingServer.material_set_param(
		material.get_rid(), &"moon_matrix", _moons_data.matrix
	)
	
	RenderingServer.material_set_param(
		refl_material.get_rid(), &"moon_matrix", _moons_data.matrix
	)
	emit_changed()

func update_moons_color() -> void:
	for p in len(_moons_data.color):
		print("MOON" + str(p) + " COLOR: " + str(_moons_data.color[p]))
	
	RenderingServer.material_set_param(
		material.get_rid(), &"moon_color", _moons_data.color
	)
	
	RenderingServer.material_set_param(
		refl_material.get_rid(), &"moon_color", _moons_data.color
	)
	emit_changed()

func update_moons_intensity() -> void:
	for p in len(_moons_data.intensity):
		print("MOON" + str(p) + " INTENSITY: " + str(_moons_data.intensity[p]))
	
	RenderingServer.material_set_param(
		material.get_rid(), &"moon_intensity", _moons_data.intensity
	)
	
	RenderingServer.material_set_param(
		refl_material.get_rid(), &"moon_intensity", _moons_data.intensity
	)
	emit_changed()

func update_moons_size() -> void:
	for p in len(_moons_data.size):
		print("MOON" + str(p) + " SIZE: " + str(_moons_data.size[p]))
	
	RenderingServer.material_set_param(
		material.get_rid(), &"moon_size", _moons_data.size
	)
	
	RenderingServer.material_set_param(
		refl_material.get_rid(), &"moon_size", _moons_data.size
	)
	emit_changed()

func update_moons_texture() -> void:
	for p in len(_moons_data.texture):
		print("MOON" + str(p) + " TEXTURE: " + str(_moons_data.texture[p]))
	
	RenderingServer.material_set_param(
		material.get_rid(), &"moon_texture", _moons_data.texture
	)
	
	RenderingServer.material_set_param(
		refl_material.get_rid(), &"moon_texture", _moons_data.texture
	)
	emit_changed()

func update_moons_mie_color() -> void:
	for p in len(_moons_data.mie_color):
		print("MOON" + str(p) + " MIE COLOR: " + str(_moons_data.mie_color[p]))
	
	RenderingServer.material_set_param(
		material.get_rid(), &"moon_mie_color", _moons_data.mie_color
	)
	
	RenderingServer.material_set_param(
		refl_material.get_rid(), &"moon_mie_color", _moons_data.mie_color
	)
	emit_changed()

func update_moons_mie_intensity() -> void:
	for p in len(_moons_data.mie_intensity):
		print("MOON" + str(p) + " MIE INTENSITY: " + str(_moons_data.mie_intensity[p]))
	
	RenderingServer.material_set_param(
		material.get_rid(), &"moon_mie_intensity", _moons_data.mie_intensity
	)
	
	RenderingServer.material_set_param(
		refl_material.get_rid(), &"moon_mie_intensity", _moons_data.mie_intensity
	)
	emit_changed()

func update_moons_mie_anisotropy() -> void:
	for p in len(_moons_data.mie_anisotropy):
		print("MOON" + str(p) + " MIE ANISOTROPY: " + str(_moons_data.mie_anisotropy[p]))
	
	RenderingServer.material_set_param(
		material.get_rid(), &"moon_mie_anisotropy", _moons_data.mie_anisotropy
	)
	
	RenderingServer.material_set_param(
		refl_material.get_rid(), &"moon_mie_anisotropy", _moons_data.mie_anisotropy
	)
	emit_changed()
#endregion
