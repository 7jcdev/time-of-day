# Universal Sky
# Description:
# - Standard sky material.
# License:
# - J. Cuéllar 2025 MIT License
# - See: LICENSE File.
@tool
class_name USkyStandandMaterial extends USkyMaterialBase

func material_is_valid() -> bool:
	return true

#region Celestials
#var sun_direction:= Vector3.ZERO:
	#get: return sun_direction
	#set(value):
		#sun_direction = value
		#RenderingServer.material_set_param(
			#material.get_rid(), &"sun_direction", sun_direction
		#)
		##_on_sun_direction_changed()
		#emit_changed()
#
#var moon_direction:= Vector3.ZERO:
	#get: return moon_direction
	#set(value):
		#moon_direction = value
		#RenderingServer.material_set_param(
			#_material.get_rid(), &"moon_direction", moon_direction
		#)
		##_on_moon_direction_changed()
		#emit_changed()
#endregion
