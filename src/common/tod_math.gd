class_name TOD_Math extends RefCounted

# ------------------------------------------------------------------------------
const PI_NUMBER:= 3.14159265358979
const HALF_PI:= 1.5707963267949
const INV_HALF_PI:= 0.63661977236758
const TAU_NUMBER:= 6.28318530717959
const INV_TAU:= 0.1591549430919
const Q_PI:= 0.78539816339745
const INV_Q_PI:= 1.27323954473516
const PIx4:= 12.56637061435917
const INV_PIx4:= 0.07957747154595
const PI3xE:= 0.11936620731892
const PI3x16:= 0.05968310365946
const e:= 2.71828182845905
const RAD_TO_DEG:= 57.29577951308232
const DEG_TO_RAD:= 0.01745329251994
const EPSILON:= 1.1920928955078125e-7
#const EPSILON_DBL:= 2.22044604925031308085e-16
# ------------------------------------------------------------------------------

static func saturate(p_value: float) -> float:
	return 0.0 if p_value < 0.0 else 1.0 if p_value > 1.0 else p_value

static func saturate_vec3(p_value: Vector3) -> Vector3:
	p_value.x = 0.0 if p_value.x < 0.0 else 1.0 if p_value.x > 1.0 else p_value.x
	p_value.y = 0.0 if p_value.y < 0.0 else 1.0 if p_value.y > 1.0 else p_value.y
	p_value.z = 0.0 if p_value.z < 0.0 else 1.0 if p_value.z > 1.0 else p_value.z
	return p_value

static func saturate_color(p_value: Color) -> Color:
	p_value.r = 0.0 if p_value.r < 0.0 else 1.0 if p_value.r > 1.0 else p_value.r
	p_value.g = 0.0 if p_value.g < 0.0 else 1.0 if p_value.g > 1.0 else p_value.g
	p_value.b = 0.0 if p_value.b < 0.0 else 1.0 if p_value.b > 1.0 else p_value.b
	p_value.a = 0.0 if p_value.a < 0.0 else 1.0 if p_value.a > 1.0 else p_value.a
	return p_value

static func saturate_rgb(p_value: Color) -> Color:
	p_value.r = 0.0 if p_value.r < 0.0 else 1.0 if p_value.r > 1.0 else p_value.r
	p_value.g = 0.0 if p_value.g < 0.0 else 1.0 if p_value.g > 1.0 else p_value.g
	p_value.b = 0.0 if p_value.b < 0.0 else 1.0 if p_value.b > 1.0 else p_value.b
	p_value.a = p_value.a
	return p_value

static func clamp_f(p_value: float, p_min: float, p_max: float) -> float:
	return p_min if p_value < p_min else p_max if p_value > p_max else p_value

static func clamp_vec2(p_value: Vector2, p_min: Vector2, p_max: Vector2) -> Vector2:
	p_value.x = p_min.x if p_value.x < p_min.x else p_max.x if p_value.x > p_max.x else p_value.x
	p_value.y = p_min.y if p_value.y < p_min.y else p_max.y if p_value.y > p_max.y else p_value.y
	return p_value

static func clamp_vec3(p_value: Vector3, p_min: Vector3, p_max: Vector3) -> Vector3:
	p_value.x = p_min.x if p_value.x < p_min.x else p_max.x if p_value.x > p_max.x else p_value.x
	p_value.y = p_min.y if p_value.y < p_min.y else p_max.y if p_value.y > p_max.y else p_value.y
	p_value.z = p_min.z if p_value.z < p_min.z else p_max.z if p_value.z > p_max.z else p_value.z
	return p_value

static func rev(p_value: float) -> float:
	return p_value - floori(p_value / 360.0) * 360.0

static func lerp_f(p_from: float, p_to: float, p_t: float) -> float:
	return (1.0 - p_t) * p_from + p_t * p_to

static func lerp_vec3(p_from: Vector3, p_to: Vector3, p_t: float) -> Vector3:
	p_from.x = (1.0 - p_t) * p_from.x + p_t * p_to.x
	p_from.y = (1.0 - p_t) * p_from.y + p_t * p_to.y
	p_from.z = (1.0 - p_t) * p_from.z + p_t * p_to.z
	
	return p_from

static func lerp_color(p_from: Color, p_to: Color, p_t: float) -> Color:
	p_from.r = (1.0 - p_t) * p_from.r + p_t * p_to.r
	p_from.g = (1.0 - p_t) * p_from.g + p_t * p_to.g
	p_from.b = (1.0 - p_t) * p_from.b + p_t * p_to.b
	p_from.a = (1.0 - p_t) * p_from.a + p_t * p_to.a
	
	return p_from

static func lerp_rgb(p_from: Color, p_to: Color, p_t: float) -> Color:
	p_from.r = (1.0 - p_t) * p_from.r + p_t * p_to.r
	p_from.g = (1.0 - p_t) * p_from.g + p_t * p_to.g
	p_from.b = (1.0 - p_t) * p_from.b + p_t * p_to.b
	p_from.a = 1.0
	
	return p_from

static func to_orbit(p_theta: float, p_pi: float, p_radius: float = 1.0) -> Vector3:
	var sinTheta: float = sin(p_theta)
	var cosTheta: float = cos(p_theta)
	var sinPI:    float = sin(p_pi)
	var cosPI:    float = cos(p_pi)
	
	return Vector3((sinTheta * sinPI) * p_radius,
		cosTheta  * p_radius, (sinTheta * cosPI) * p_radius)

static func distance(p_a: Vector3, p_b: Vector3) -> float:
	var x: float = p_a.x - p_b.x
	var y: float = p_a.y - p_b.y
	var z: float = p_a.z - p_b.z
	
	return sqrt(x * x + y * y + z * z)
