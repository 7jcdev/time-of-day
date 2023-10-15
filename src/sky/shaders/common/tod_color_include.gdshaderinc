#ifndef TOD_COLOR_INCLUDE
#define TOD_COLOR_INCLUDE

#define saturate(x) clamp(x, 0.0, 1.0)

vec3 contrastLevel(vec3 x, float level){
	return mix(x, x*x*x, level);
}

#ifdef TONEMAP_ACES
vec3 tonemap(vec3 color, float exposure, float level){
	color.rgb *= exposure;
	const vec3  a = vec3(2.51);
	const float b = 0.03;
	const float c = 2.43;
	const float d = 0.59;
	const float e = 0.14;
	vec3 ret = (color.rgb * (a * color.rgb + b)) / (color.rgb * (c * color.rgb + d) + e);
	return mix(color.rgb, ret, level);
}
#elif defined TONEMAP_REINHARD
// Añadido, documentar.
vec3 tonemap(vec3 color, float exposure, float level) {
	return mix(color, (6.0 * color + color) / (color * 6.0 + 6.0), level)  * exposure;
}
#else // Photo
vec3 tonemap(vec3 col, float exposure, float level){
	return mix(col.rgb * exposure,(1.0 - exp2(-col.rgb * exposure * 2.0)), level);
}
#endif

// https://www.iryoku.com/next-generation-post-processing-in-call-of-duty-advanced-warfare
vec3 interleavedGradientNoise(vec2 pos) {
	const vec3 magic = vec3(0.06711056f, 0.00583715f, 52.9829189f);
	float res = fract(magic.z * fract(dot(pos, magic.xy))) * 2.0 - 1.0;
	return vec3(res, -res, res) * 0.00392156862745; // / 255.0;
}

#define COLOR_CORRECTION(col) col.rgb = tonemap(col.rgb, tod_exposure, tod_tonemap_level);  \
	col.rgb += tod_apply_debanding ? interleavedGradientNoise(FRAGCOORD.xy): vec3(0.0)

float remap(float value, float fromMin, float fromMax, float toMin, float toMax){
	return toMin + (value - fromMin) * (toMax - toMin) / (fromMax - fromMin);
}

#endif