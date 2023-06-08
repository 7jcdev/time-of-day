#ifndef TOD_SKY_COMMON
#define TOD_SKY_COMMON

// Constants.
const float kPI          = 3.1415927f;
const float kINV_PI      = 0.3183098f;
const float kHALF_PI     = 1.5707963f;
const float kINV_HALF_PI = 0.6366198f;
const float kQRT_PI      = 0.7853982f;
const float kINV_QRT_PI  = 1.2732395f;
const float kPI4         = 12.5663706f;
const float kINV_PI4     = 0.0795775f;
const float k3PI16       = 0.1193662f;
const float kTAU         = 6.2831853f;
const float kINV_TAU     = 0.1591549f;
const float kE           = 2.7182818f;
// -----------------------------------------------------------------------------

// Color.
#define saturate(x) clamp(x, 0.0, 1.0)

vec3 contrastLevel(vec3 x, float level){
	return mix(x, x*x*x, level);
}

vec3 tonemapPhoto(vec3 col, float exposure, float level){
	return mix(col.rgb * exposure,(1.0 - exp2(-col.rgb * exposure * 2.0)), level);
}

// Añadido, documentar.
vec3 tonemapReinhard(vec3 color, float exposure, float level) {
	return mix(color, (6.0 * color + color) / (color * 6.0 + 6.0), level)  * exposure;
}

vec3 tonemapACES(vec3 color, float exposure, float level){
	color.rgb *= exposure;
	const vec3  a = vec3(2.51);
	const float b = 0.03;
	const float c = 2.43;
	const float d = 0.59;
	const float e = 0.14;
	vec3 ret = (color.rgb * (a * color.rgb + b)) / (color.rgb * (c * color.rgb + d) + e);
	return mix(color.rgb, ret, level);
}

// https://www.iryoku.com/next-generation-post-processing-in-call-of-duty-advanced-warfare
vec3 interleavedGradientNoise(vec2 pos) {
	const vec3 magic = vec3(0.06711056f, 0.00583715f, 52.9829189f);
	float res = fract(magic.z * fract(dot(pos, magic.xy))) * 2.0 - 1.0;
	return vec3(res, -res, res) * 0.00392156862745; // / 255.0;
}

// Simple random from https://thebookofshaders.com/10/
float simpleRandom(vec2 st){
	return fract(sin(dot(st.xy, vec2(12.9898,78.233)))*43758.5453123);
}

#define COLOR_CORRECTION(col) col.rgb = tonemapPhoto(col.rgb, tod_exposure, tod_tonemap_level);  \
	col.rgb += tod_apply_debanding ? interleavedGradientNoise(FRAGCOORD.xy): vec3(0.0)


float remap(float value, float fromMin, float fromMax, float toMin, float toMax){
	return toMin + (value - fromMin) * (toMax - toMin) / (fromMax - fromMin);
}

// -------------------------------------------------------------------------------------------------

// Coords.
// -------------------------------------------------------------------------------------------------
vec2 equirectUV(vec3 norm){
	vec2 ret;
	ret.x = (atan(norm.x, norm.z) + kPI) * kINV_TAU;
	ret.y = acos(norm.y) * kINV_PI;
	return ret;
}
// -------------------------------------------------------------------------------------------------

#endif // TOD Sky Common.