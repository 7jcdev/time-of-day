@tool
extends Node
signal sun_added
signal sun_removed
signal moon_added
signal moon_removed

var _sun_celestials: Array[TOD_Sun]
var _moon_celestials: Array[TOD_Moon]

func get_sun_celestials() -> Array[TOD_Sun]:
	return _sun_celestials

func get_moon_celestials() -> Array[TOD_Moon]:
	return _moon_celestials

#func _init() -> void:
#	sun_celestials.make_read_only()
#	moon_celestials.make_read_only()

func add_sun(p_sun: TOD_Sun) -> void:
	_sun_celestials.push_back(p_sun)
	emit_signal(&"sun_added")

func remove_sun(p_sun: TOD_Sun) -> void:
	_sun_celestials.erase(p_sun)
	emit_signal(&"sun_removed")

func add_moon(p_moon: TOD_Moon) -> void:
	_moon_celestials.push_back(p_moon)
	emit_signal(&"moon_added")

func remove_moon(p_moon: TOD_Moon) -> void:
	_moon_celestials.erase(p_moon)
	emit_signal(&"moon_removed")
