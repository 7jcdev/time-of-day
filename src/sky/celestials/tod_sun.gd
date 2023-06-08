@tool @icon('res://addons/jc.time-of-day/icons/sun.svg')
class_name TOD_Sun extends TOD_Celestial

enum SunValueType{COLOR = 0, INTENSITY = 1, SIZE = 2}
const VALUE_CHANGED:= &'value_changed'
signal value_changed(type)

@export_group('Disk')
@export_color_no_alpha
var disk_color:= Color(1, 0.7058, 0.4470):
	get: return disk_color
	set(value):
		disk_color = value
		emit_signal(VALUE_CHANGED, SunValueType.COLOR)

@export 
var disk_intensity:= 2.0:
	get: return disk_intensity
	set(value):
		disk_intensity = value
		emit_signal(VALUE_CHANGED, SunValueType.INTENSITY)

@export 
var disk_size:= 0.005:
	get: return disk_size
	set(value):
		disk_size = value
		emit_signal(VALUE_CHANGED, SunValueType.SIZE)

var parent: TOD_Sky = null
func _initialize_params() -> void:
	super()
	disk_color = disk_color
	disk_intensity = disk_intensity
	disk_size = disk_size
	#anisotropy = anisotropy
