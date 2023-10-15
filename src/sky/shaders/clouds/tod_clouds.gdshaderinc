#ifndef TOD_CLOUDS
#define TOD_CLOUDS
#include "res://addons/time-of-day/src/sky/shaders/common/tod_color_include.gdshaderinc"
#include "res://addons/time-of-day/src/sky/shaders/common/tod_sky_variables.gdshaderinc"

// Dynamic clouds based on:
// https://github.com/danilw/godot-utils-and-other/blob/master/Dynamic%20sky%20and%20reflection/shaders/Sky.shader

uniform sampler2D tod_clouds_noise_tex: source_color;
uniform float tod_clouds_noise_freq = 3.0;
uniform float tod_clouds_smooth = 0.05;
uniform float tod_clouds_size = 0.5;
uniform float tod_clouds_shell_offset = 410.0;
uniform float tod_clouds_coverage: hint_range(0.0, 1.0) = 0.7;

uniform float tod_clouds_absorption: hint_range(0.0, 5.0) = 1.0;
uniform float tod_clouds_thickness: hint_range(0.0, 2.0) = 0.7;

uniform float tod_clouds_intensity = 1.0;
uniform vec4 tod_clouds_zenith_color: source_color;
uniform vec4 tod_clouds_horizon_color: source_color;
uniform vec4 tod_clouds_night_color: source_color;
uniform float tod_clouds_atmosphere_inject;

uniform vec3 tod_clouds_offset;
uniform float tod_clouds_offset_speed;

bool cloudsIntersectSphere(vec3 origin, vec3 dir, float radius, out vec3 normal){
	float a = dot(dir, dir);
	float b = 2.0 * dot(origin, dir);
	float c = dot(origin, origin) - radius * radius;
	float d = b * b - 4.0 * a * c;
	if(d < 0.0){
		return false;
	}
	d = sqrt(d);
	a *= 2.0;
	
	float t1 = 0.5 * (-b + d);
	float t2 = 0.5 * (-b - d);
	t1 = t1 < 0.0 ? t2 : t1;
	t2 = t2 < 0.0 ? t1 : t2;
	t1 = min(t1, t2);
	
	if(t1 < 0.0){
		return false;
	}
	normal = origin + t1 * dir;
	return true;
}

float noiseClouds(vec3 p){
	vec3 pos = vec3(p * 0.01)* tod_clouds_size;
	pos.z *= 256.0;
	
	vec2 Offset = vec2(0.317, 0.123);
	vec4 uv= vec4(0.0);
	uv.xy = pos.xy + Offset * floor(pos.z);
	uv.zw = uv.xy + Offset;
	
	float x1 = textureLod(tod_clouds_noise_tex, uv.xy, 0.0).r;
	float x2 = textureLod(tod_clouds_noise_tex, uv.zw, 0.0).r;
	return mix(x1, x2, fract(pos.z));
}

float cloudsFBM(vec3 p, float l){
	float ret;
	ret  = 0.51749673 * noiseClouds(p); p *= l;
	ret += 0.25584929 * noiseClouds(p); p *= l; 
	ret += 0.12527603 * noiseClouds(p); p *= l;
	ret += 0.06255931 * noiseClouds(p);
	
	return ret;
}

float noiseCloudsFBM(vec3 p, float freq){
	return cloudsFBM(p, freq);
}

float dynamicCloudsDensity(vec3 p, vec3 offset){
	vec3 pos = p * 0.0212242 + offset;
	float dens = noiseCloudsFBM(pos, tod_clouds_noise_freq);
	float cov = 1.0-(tod_clouds_coverage);
	dens *= smoothstep(cov-tod_clouds_smooth, cov+tod_clouds_smooth, dens);
	return saturate(dens);
}

vec4 renderDynamicClouds(vec3 origin, vec3 dir, float _time, in vec3 scatter){
	vec4 ret = vec4(0.0, 0.0, 0.0, 1.0);
	origin = vec3(origin.x, origin.y - tod_clouds_shell_offset, origin.z);
	
	vec3 normal = vec3(0.0);
	float alpha = 0.0;
	const int steps = 24;
	if(cloudsIntersectSphere(origin, dir, 500.0, normal)){
		float marchStep = tod_clouds_thickness * 0.041;
		vec3 dirStep = dir / dir.y * marchStep;
		vec3 position = normal;
		float t = 1.0;
		vec3 offsets = tod_clouds_offset * tod_clouds_offset_speed * _time;
		for (int i = 0; i < steps; i++) {
			float h = float(i) * 0.041;
			float density = dynamicCloudsDensity(position, offsets);
			float ti = exp(-tod_clouds_absorption * density * marchStep);
			t*=ti;
			//if (t < 0.01) break;
			ret.rgb += t * (exp(h) * 0.571428571) * density * marchStep;
			
			alpha += (1.0 - ti) * (1.0 - alpha);
			position += dirStep;
			//if (length(position) > 1e3) break;
		}
		
		vec3 tint = mix(tod_clouds_zenith_color.rgb, tod_clouds_horizon_color.rgb, 
				saturate((1.0 - tod_sun_direction.y)));
		
		tint = mix(tint, tod_clouds_night_color.rgb, saturate(-tod_sun_direction.y+0.70));
		tint = mix(tint.rgb, tint.rgb * scatter + scatter, tod_clouds_atmosphere_inject);
		
		ret.rgb = mix(tint, vec3(0.0), exp(-ret.y)) * tod_clouds_intensity;
		ret.a = alpha * alpha;
	}
	return ret;
}

// Experimental clouds.
/*vec4 renderExperimentalClouds(vec3 origin, vec3 dir, float _time, in vec3 scatter){
	vec4 ret = vec4(0.0);
	origin = vec3(origin.x, origin.y - clouds_shell_offset, origin.z);
	vec3 normal = vec3(0.0); float alpha = 0.0;
	if(cloudsIntersectSphere(origin, dir,500.0, normal)){
		const int steps = 8;
		vec3 marchSteps = mix(
			tod_sun_direction.xyz, tod_moon_direction.xyz,
			saturate(- tod_sun_direction.y)
		) * clouds_thickness;
		vec3 offsets = clouds_offset * clouds_offset_speed * _time;
		
		float density = 0.0; float a = 0.0;
		for(int i = 0; i < steps; i++){
			vec3 p = (normal * clouds_size) + float(i) * marchSteps;
			float d = dynamicCloudsDensity(p, offsets);
			density += d;
		}
		a += dynamicCloudsDensity(normal * clouds_size, offsets) * float(steps);
		
		float t = exp2(-clouds_absorption * density);
		vec3 colA = mix(clouds_zenith_color.rgb, clouds_horizon_color.rgb, saturate((1.0 - tod_sun_direction.y)-0.50));
		vec3 colB = mix(colA, clouds_night_color.rgb, saturate(-tod_sun_direction.y+.60));
		
		colB.rgb = mix(colB.rgb, colB.rgb * scatter + scatter, clouds_atmosphere_inject);
		ret.rgb = mix(vec3(0.0),colB.rgb, t) * clouds_intensity;
		
		alpha = saturate(a);
		return vec4(clamp(ret.rgb, 0.0, 1.0), alpha);
	}
	return ret;
}*/

#endif