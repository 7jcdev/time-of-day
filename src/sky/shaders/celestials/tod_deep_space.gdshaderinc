#ifndef TOD_DEEP_SPACE
#define TOD_DEEP_SPACE
#include "res://addons/time-of-day/src/sky/shaders/common/tod_color_include.gdshaderinc"
#include "res://addons/time-of-day/src/sky/shaders/common/tod_sky_variables.gdshaderinc"
//#include "res://addons/time-of-day/src/sky/shaders/common/tod_random_include.gdshaderinc"

// Background.
uniform sampler2D tod_background_texture: source_color;
uniform vec4 tod_background_color: source_color;

// Stars Field.
uniform sampler2D tod_stars_field_texture: source_color;
uniform sampler2D tod_noise_tex: source_color;
uniform vec4 tod_stars_field_color: source_color;
uniform float tod_stars_field_intensity;
uniform float tod_stars_scintillation;
uniform float tod_stars_scintillation_speed;
uniform mat3 tod_deep_space_matrix;

vec3 getDeepSpaceCoords(vec3 pos){
	return tod_deep_space_matrix * pos.xyz;
}

vec3 getBackground(vec2 uv){
	return contrastLevel(
		textureLod(tod_background_texture, uv, 0.0).rgb * tod_background_color.rgb,
			tod_background_color.a
	);
}

vec3 getStarsField(vec2 uv){
	float field = textureLod(tod_stars_field_texture, uv, 0.0).r;
	field = mix(field, field 
		* saturate(sin(field * ((TIME*20.0) * tod_stars_scintillation_speed))), 
		tod_stars_scintillation
	);
	return saturate(field) * tod_stars_field_intensity * tod_stars_field_color.rgb;
}
#endif