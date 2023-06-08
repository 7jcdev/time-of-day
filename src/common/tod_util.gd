class_name TOD_Util

# Interpolation.
static func interpolate_full(p_dir: float) -> float:
	return (1.0 - p_dir) * 0.5

static func interpolate_by_above(p_dir: float) -> float:
	return 1.0 - p_dir

static func interpolate_by_below(p_dir: float) -> float:
	return 1.0 + p_dir
# ------------------------------------------------------------------------------

# Color.
enum ColorChannel{
	RED, GREEN, BLUE, ALPHA
}

static func get_color_channel(p_channel: int) -> Color:
	match(p_channel):
		ColorChannel.RED: 
			return Color(1.0, 0.0, 0.0, 0.0)
		ColorChannel.GREEN: 
			return Color(0.0, 1.0, 0.0, 0.0)
		ColorChannel.BLUE: 
			return Color(0.0, 0.0, 1.0, 0.0)
		ColorChannel.ALPHA: 
			return Color(0.0, 0.0, 0.0, 1.0)
	return Color.BLACK
