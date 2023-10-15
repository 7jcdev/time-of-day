#ifndef TOD_SKY_VARIABLES
#define TOD_SKY_VARIABLES

// Sun.
uniform vec3 tod_sun_direction;
uniform vec4 tod_sun_disk_color: source_color;
uniform float tod_sun_disk_intensity;
uniform float tod_sun_disk_size;

// Moon.
uniform vec3 tod_moon_direction;
uniform vec4 tod_moon_color: source_color;
uniform float tod_moon_intensity;
uniform float tod_moon_size;
uniform sampler2D tod_moon_texture;
uniform mat3 tod_moon_matrix;

// Atmosphere.
uniform bool tod_enable_night_scatter;
uniform float tod_atm_night_intensity;

uniform bool tod_apply_debanding;
uniform float tod_exposure;
uniform float tod_tonemap_level;
uniform float tod_horizon_level;

#endif