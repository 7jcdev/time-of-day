#ifndef TOD_CLOUDS
#define TOD_CLOUDS
#include "res://addons/time-of-day/src/sky/shaders/common/tod_color_include.gdshaderinc"
#include "res://addons/time-of-day/src/sky/shaders/common/tod_sky_variables.gdshaderinc"

#ifndef LEGACY_CLOUDS
#define LEGACY_CLOUDS
#endif

// Dynamic clouds based on:
// https://github.com/danilw/godot-utils-and-other/blob/master/Dynamic%20sky%20and%20reflection/shaders/Sky.shader

#ifdef LEGACY_CLOUDS
uniform sampler2D tod_clouds_noise_tex: source_color;
uniform float tod_clouds_noise_freq = 3.0;
uniform float tod_clouds_smooth = 0.05;
uniform float tod_clouds_size = 0.5;
uniform float tod_clouds_shell_offset = 410.0;
uniform float tod_clouds_coverage: hint_range(0.0, 1.0) = 0.7;

uniform float tod_clouds_absorption: hint_range(0.0, 5.0) = 1.0;
uniform float tod_clouds_thickness: hint_range(0.0, 2.0) = 0.7;

uniform float tod_clouds_intensity = 1.0;
uniform vec4 tod_clouds_color: source_color;
uniform vec4 tod_clouds_night_color: source_color;
uniform vec3 tod_clouds_offset;
uniform float tod_clouds_offset_speed;
uniform int tod_clouds_samples;

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
	uv.xy = pos.xy + Offset* floor(pos.z);
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
	dens = smoothstep(cov-tod_clouds_smooth, cov+tod_clouds_smooth, dens);
	return saturate(dens);
}

vec4 renderDynamicClouds(vec3 origin, vec3 dir, float _time, in vec3 scatter){
	vec4 ret = vec4(0.0, 0.0, 0.0, 1.0);
	origin = vec3(origin.x, origin.y - tod_clouds_shell_offset, origin.z);
	vec3 lightPos = mix(
		tod_sun_direction.xyz, tod_moon_direction.xyz,
			saturate(- tod_sun_direction.y)
	);
	
	vec3 normal = vec3(0.0); float alpha = 0.0;
	//const int cloudsSteps = 24;
	float cloudsStepsRCP = 1.0/float(tod_clouds_samples);
	//const int shadowSteps = 4;
	//const float shadowStepsRCP = 1.0/float(shadowSteps);
	if(cloudsIntersectSphere(origin, dir, 500.0, normal)){
		float marchStep = tod_clouds_thickness * cloudsStepsRCP;
		vec3 dirStep = dir / dir.y * marchStep;
		vec3 position = normal;
		vec3 offsets = tod_clouds_offset * tod_clouds_offset_speed * _time;
		vec3 t = vec3(1.0);
		float density = 0.0;
		for (int i = 0; i < tod_clouds_samples; i++) {
			float h = float(i) * cloudsStepsRCP;
			density += dynamicCloudsDensity(position, offsets);
			float ti = exp(-tod_clouds_absorption * density * marchStep);
			
			/*float shadow = 0.0;
			for (int s = 0; s < shadowSteps; s++){
				vec3 p = normal + (float(s) * 0.3333333) * lightPos;
				shadow += dynamicCloudsDensity(p, offsets);
			}*/
			//float tic = exp2(shadow * -tod_clouds_absorption * marchStep * shadowStepsRCP);
			//t*= (ti + tic) * 0.5;
			
			t*=ti;
			//if (t < 0.001) break;
			
			ret.rgb += t * (exp(h) * 0.571428571) * density * marchStep;
			alpha += (1.0 - ti) * (1.0 - alpha);
			position += dirStep;
			//if (length(position) > 1e3) break;
		}
		
		vec3 tint = tod_clouds_color.rgb;
		tint = mix(tint, tod_clouds_night_color.rgb, saturate(-tod_sun_direction.y+0.75));
		ret.rgb *= tint.rgb * tod_clouds_intensity;
		ret.rgb += scatter * 0.3;
		ret.a = alpha * alpha;
		return ret;
	}
	return ret;
}
#endif
#endif