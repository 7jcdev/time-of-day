# Universal Sky
# Description:
# - Sun data arrays.
# License:
# - J. Cuéllar 2025 MIT License
# - See: LICENSE File.
extends RefCounted
class_name USkyCelestialsData

var direction: PackedVector3Array
var size: PackedFloat32Array
var color: PackedColorArray
var intensity: PackedFloat32Array
	
	# Mie.
var mie_color: PackedColorArray
var mie_intensity: PackedFloat32Array
var mie_anisotropy: PackedFloat32Array
