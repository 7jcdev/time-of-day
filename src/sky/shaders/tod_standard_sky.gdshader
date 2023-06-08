shader_type sky;
render_mode use_quarter_res_pass, use_half_res_pass;
#include "res://addons/jc.time-of-day/src/sky/shaders/tod_sky_include.gdshaderinc"
#include "res://addons/jc.time-of-day/src/sky/shaders/tod_sky_common.gdshaderinc"
#include "res://addons/jc.time-of-day/src/sky/shaders/tod_scattering_common.gdshaderinc"
#include "res://addons/jc.time-of-day/src/sky/shaders/tod_clouds.gdshaderinc"

#define HIGH_QUALITY_SUN_DISK
#define HALF_CLOUDS

// General Settings
// -----------------------------------------------------------------------------
uniform float horizon_level;
uniform float sun_uMuS;

// Deep Space.
// -----------------------------------------------------------------------------
// Background.
uniform sampler2D background_texture: source_color;
uniform vec4 background_color: source_color;

// Stars Field.
uniform sampler2D stars_field_texture: source_color;
uniform sampler2D noise_tex: source_color;
uniform vec4 stars_field_color: source_color;
uniform float stars_scintillation;
uniform float stars_scintillation_speed;
uniform mat3 deep_space_matrix;

// Atmospheric Scattering.
// -----------------------------------------------------------------------------
// Rayleigh.
uniform float atm_sunE;
uniform float atm_darkness;
uniform float atm_thickness;
uniform float atm_rayleigh_level;
uniform vec4 atm_tint: source_color;
uniform vec4 atm_horizon_light_tint: source_color;
uniform vec4 atm_night_tint: source_color;
uniform vec3 atm_beta_ray;

// Mie.
uniform vec3 atm_beta_mie;
uniform vec4 atm_sun_mie_tint: source_color;
uniform float atm_sun_mie_intensity;
uniform vec3 atm_sun_partial_mie_phase;
uniform vec4 atm_moon_mie_tint: source_color;
uniform float atm_moon_mie_intensity;
uniform vec3 atm_moon_partial_mie_phase;
uniform vec4 atm_ground_color: source_color;

const float RAYLEIGH_ZENITH_LENGTH = 8.4e3;
const float MIE_ZENITH_LENGTH = 1.25e3;
// -----------------------------------------------------------------------------

struct SphereRay{
	vec3 origin;
	vec3 direction;
	float radius;
};

float disk(vec3 pos, vec3 dir, lowp float size){
	mediump float ret = 0.0;
#ifdef HIGH_QUALITY_SUN_DISK
	ret = (pow(2.0- (2.0 * dot(dir, pos)), -1.5) * size*0.001);
#else
	ret = 1.0 - step(size, length(pos - dir));
#endif
	ret = min(50.0, ret); // Prevent reflection artifacts.
	return ret;
}

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

void opticalDepth(float y, out vec3 sr, out vec3 sm){
	vec3 zenith = max(0.03, y + 0.03) + (max(0.0, -y) * atm_ground_color.xyz);
	zenith = 1.0 / zenith;
	sr = vec3(zenith * RAYLEIGH_ZENITH_LENGTH * atm_rayleigh_level);
	sm = vec3(zenith * MIE_ZENITH_LENGTH);
}
// -----------------------------------------------------------------------------

void sky(){
	vec3 finalColor = vec3(0.0);
	vec3 worldPos = EYEDIR;
	vec3 horizonBlend = mix(
		vec3(0.0), vec3(1.0), smoothstep(-0.1, 1.0, dot(vec3(0.0, 1.0, 0.0), worldPos+horizon_level)*10.0)
	);
	
	// Atmospheric Scattering.
	// -------------------------------------------------------------------------
	vec3 scatter = vec3(0.0);
	{
		float suMus = sun_uMuS - 0.6; //0.65;
		float sunset = mix(suMus, suMus * 0.05,atm_thickness-1.0);
		sunset = saturate(sunset);
	
		vec3 sr, sm;
		opticalDepth(worldPos.y + horizon_level, sr, sm);
		vec3 betaMie = atm_beta_mie;
		vec3 betaRay = atm_beta_ray * atm_thickness;
		
		vec3 extinction = saturate(exp(-betaRay * sr + betaMie * sm));
		//vec3 extincH = (1.0-(extinction*0.5)) * sr * 0.00002; // Use day tint gradient for better artistic results.
		vec3 extincH = (1.0 - extinction); 
		vec3 finalExtc = mix((1.0-extinction), extinction * extincH, 1.0-sunset);
		
		float sunMu = dot(tod_sun_direction, worldPos);
		float rayleighPhase = rayleighPhase(sunMu);
		
		vec3 BRT = betaRay * rayleighPhase;
		vec3 BMT = betaMie * miePhasePartial(sunMu, atm_sun_partial_mie_phase) * horizonBlend;
		BMT *= atm_sun_mie_intensity * atm_sun_mie_tint.rgb;
		vec3 BRMT = (BRT + BMT) / (betaRay + betaMie);
		
		vec3 Lin = atm_sunE * (BRMT * finalExtc) * atm_tint.rgb * sun_uMuS;
		Lin = mix(Lin, Lin * (1.0 - extinction), atm_darkness);
		
		// Night.
		float moonMu = dot(tod_moon_direction, worldPos);
		vec3 nLin = (1.0 - extinction) * atm_night_tint.rgb;
		 nLin += miePhasePartial(moonMu, atm_moon_partial_mie_phase) * atm_moon_mie_tint.rgb * 
			atm_moon_mie_intensity * horizonBlend;
		 nLin = mix(nLin,  nLin * (1.0 - extinction), atm_darkness);
		
		scatter = Lin + nLin;
		//scatter = mix(scatter, scatter * scatter, 0.5);
	}
	worldPos.y += horizon_level;
	// -------------------------------------------------------------------------
	
	// Deep Space.
	// ---------------------------------------------------------------------------------------------
	vec3 deepSpace = vec3(0.0);
	vec3 deepSpaceCoords = (deep_space_matrix * worldPos.xyz);
	vec2 deepSpaceUV = equirectUV(normalize(deepSpaceCoords));
	{
		// Background.
		vec3 background = contrastLevel(
			textureLod(background_texture, deepSpaceUV, 0.0).rgb * background_color.rgb,
			background_color.a
		);
		deepSpace += background.rgb;// * moonMask;
		
		// Stars Field.
		float starsScintillation = 1.0-simpleRandom(
			SKY_COORDS + ((TIME * 0.00001) * stars_scintillation_speed)
		);
		starsScintillation = mix(1.0, starsScintillation * 4.0, stars_scintillation);
		
		vec3 starsField = textureLod(stars_field_texture, deepSpaceUV, 0.0).rgb * stars_field_color.rgb;
		starsField = saturate(mix(starsField.rgb, starsField.rgb * starsScintillation, stars_scintillation));
		
		deepSpace.rgb += starsField.rgb;
	}
	
	// Near Space.
	// -------------------------------------------------------------------------
	vec3 nearSpace = vec3(0.0);
	vec3 sunColor = vec3(0.0);
	// Sun.
	{
		float sunMu = dot(tod_sun_direction, worldPos);
		sunColor = disk(worldPos, tod_sun_direction, tod_sun_disk_size) * 
				tod_sun_disk_color.rgb * tod_sun_disk_intensity;
		
		sunColor *= scatter;
		
		//nearSpace += sunColor;
		deepSpace.rgb *= saturate(1.0-(tod_sun_direction.y+1.0));
	}
	
	// Moon
	vec3 moonColor = vec3(0.0); float moonMask = 0.0;
	{
		float moonMu = dot(tod_moon_direction, worldPos);
		
		// Sphere Intersection.
		SphereRay ray;
		ray.origin = worldPos; ray.direction = tod_moon_direction;
		ray.radius = tod_moon_size;
		
		float mask = 0.0;
		float isphere = moonSphere(ray, mask);
		
		// Lighting.
		float ndotL = 0.0;
		vec3 normal = normalize(tod_moon_direction - worldPos * isphere);
		ndotL += saturate(dot(normal, -tod_sun_direction));
		
		// Texture.
		vec3 texCoords = (tod_moon_matrix * normal).xyz;
		texCoords.xy = equirectUV(texCoords);
		texCoords.x += -0.3;
		
		vec4 color = texture(tod_moon_texture, texCoords.xy);
		color.rgb *= tod_moon_color.rgb * tod_moon_intensity;
		color.rgb = contrastLevel(color.rgb, tod_moon_color.a);
		
		// Result.
		float fix = saturate(dot(worldPos.xyz, tod_moon_direction.xyz));
		vec3 result = (mask * color.rgb) * ndotL * fix;
		
		moonColor += result;
		moonMask = saturate(1.0 - mask);
	}
	nearSpace += (sunColor * moonMask) + moonColor;
	deepSpace.rgb *= moonMask;
	
	finalColor += (nearSpace + deepSpace) * horizonBlend;
	finalColor += scatter;

	vec4 clouds = (renderDynamicClouds(vec3(0.0, -horizon_level, 0.0), worldPos, TIME, scatter));
#ifndef HALF_CLOUDS
	finalColor = mix(finalColor, clouds.rgb, clouds.a * horizonBlend);
#endif
	if(AT_QUARTER_RES_PASS && AT_CUBEMAP_PASS)
	{
	#ifdef HALF_CLOUDS
		COLOR = mix(finalColor, clouds.rgb, clouds.a * horizonBlend);
	#else
		COLOR = finalColor;
	#endif
		ALPHA = 1.0;
	}
	else if (AT_HALF_RES_PASS && !AT_CUBEMAP_PASS)
	{
	#ifdef HALF_CLOUDS
		COLOR = clouds.rgb;
		ALPHA = clouds.a * horizonBlend.r;
	#endif
	}
	else if(AT_CUBEMAP_PASS)
	{
		
		COLOR = QUARTER_RES_COLOR.rgb;
	}
	else
	{
	#ifndef HALF_CLOUDS
		COLOR = finalColor;
	#else
		COLOR = mix(finalColor, HALF_RES_COLOR.rgb, HALF_RES_COLOR.a);
	#endif
	}
	COLOR_CORRECTION(COLOR);
}