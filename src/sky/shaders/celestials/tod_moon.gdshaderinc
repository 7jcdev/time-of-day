#ifndef TOD_MOON
#define TOD_MOON
#include "res://addons/time-of-day/src/sky/shaders/common/tod_sky_variables.gdshaderinc"
#include "res://addons/time-of-day/src/sky/shaders/common/tod_color_include.gdshaderinc"
#include "res://addons/time-of-day/src/sky/shaders/common/tod_coords_include.gdshaderinc"

struct SphereRay{
	vec3 origin;
	vec3 direction;
	float radius;
};

float moonSphere(SphereRay ray, inout float mask){
	ray.origin = -ray.origin;
	//float a = dot(ray.direction, ray.direction);
	float b = dot(ray.direction, ray.origin);
	float c = dot(ray.origin, ray.origin) - ray.radius * ray.radius;
	float d = b * b - c;
	if(d < 0.0){
		return -1.0;
	}
	d = sqrt(d);
	float ret = -b - d;
	mask = ret > -1.0 ? 1.0 : 0.0;
	
	return ret;
}

vec4 computeMoon(vec3 pos){
	float moonMu = dot(tod_moon_direction, pos);
	
	SphereRay ray;
	ray.origin = pos;
	ray.direction = tod_moon_direction;
	ray.radius = tod_moon_size;
	
	float mask = 0.0;
	float isphere = moonSphere(ray, mask);
	
	float ndotL = 0.0;
	vec3 normal = normalize(tod_moon_direction - pos * isphere);
	ndotL += saturate(dot(normal, -tod_sun_direction));
	
	vec3 texCoords = (tod_moon_matrix * normal).xyz;
	texCoords.xy = equirectUV(texCoords);
	texCoords.x += -0.3;
	
	vec4 color = texture(tod_moon_texture, texCoords.xy);
	color.rgb *= tod_moon_color.rgb * tod_moon_intensity;
	color.rgb = contrastLevel(color.rgb, tod_moon_color.a);
	
	float fix = saturate(dot(pos.xyz, tod_moon_direction.xyz));
	vec3 result = (mask * color.rgb) * ndotL * fix;
	
	return vec4(result.rgb, saturate(1.0 - mask));
}
#endif