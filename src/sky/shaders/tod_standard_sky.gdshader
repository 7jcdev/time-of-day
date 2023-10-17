shader_type sky;
render_mode use_quarter_res_pass, use_half_res_pass;
#define HIGH_QUALITY_SUN_DISK
#define TONEMAP_ACES
#define LEGACY_CLOUDS
#include "atmosphere/tod_standard_atmosphere.gdshaderinc"
#include "celestials/tod_sun.gdshaderinc"
#include "celestials/tod_moon.gdshaderinc"
#include "celestials/tod_deep_space.gdshaderinc"
#include "clouds/tod_clouds.gdshaderinc"

void sky(){
	vec3 worldPos = EYEDIR;
	vec3 horizonBlend = mix(vec3(0.0), vec3(1.0),
		smoothstep(-0.1, 1.0, dot(vec3(0.0, 1.0, 0.0), 
		worldPos + vec3(0.0, tod_horizon_level, 0.0))*10.0));
	
	vec3 finalColor = vec3(0.0);
	vec3 scatter = atmosphericScattering(worldPos, horizonBlend);
	
	vec3 deepSpace = vec3(0.0);
	vec3 deepSpaceCoords = getDeepSpaceCoords(worldPos);
	deepSpace += getBackground(equirectUV(deepSpaceCoords));
	deepSpace += getStarsField(equirectUV(deepSpaceCoords));
	
	vec3 nearSpace = vec3(0.0);
	vec3 sun = sunDisk(worldPos, tod_sun_direction, 
		tod_sun_disk_size) * tod_sun_disk_color.rgb;
	
	vec4 moon = computeMoon(worldPos);
	nearSpace += (sun.rgb * moon.a) + moon.rgb;
	deepSpace *= moon.a;
	deepSpace.rgb *= saturate(1.0-(tod_sun_direction.y+0.85));
	
	finalColor += (deepSpace + nearSpace) * horizonBlend;
	finalColor += scatter;
	
	vec4 clouds = (renderDynamicClouds(vec3(0.0, tod_horizon_level * 500.0, 0.0), worldPos, TIME, scatter));
	//finalColor = mix(finalColor, clouds.rgb, clouds.a * horizonBlend);
	if(AT_QUARTER_RES_PASS && AT_CUBEMAP_PASS){
		COLOR = mix(finalColor, clouds.rgb, clouds.a * horizonBlend);
		ALPHA = 1.0;
	}
	else if (AT_HALF_RES_PASS && !AT_CUBEMAP_PASS){
		COLOR = clouds.rgb;
		ALPHA = clouds.a * horizonBlend.r;
	}
	else if(AT_CUBEMAP_PASS){
		COLOR = QUARTER_RES_COLOR.rgb;
	}
	else{
		COLOR = mix(finalColor, HALF_RES_COLOR.rgb, HALF_RES_COLOR.a);
	}
	COLOR = COLOR_CORRECTION(COLOR);
}