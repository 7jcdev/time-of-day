@tool @icon("res://addons/time-of-day/icons/sun.svg")
extends TOD_Celestial
class_name TOD_Sun

enum SunValueType{ COLOR = 0, INTENSITY = 1, SIZE = 2 }

@export_group("Disk")
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

func _on_enter_tree() -> void:
	GlobalCelestials.add_sun(self)
	super()

func _exit_tree() -> void:
	GlobalCelestials.remove_sun(self)

func _initialize_params() -> void:
	super()
	disk_color = disk_color
	disk_intensity = disk_intensity
	disk_size = disk_size
	
