#ifndef TOD_STANDARD_ATMOSPHERE
#define TOD_STANDARD_ATMOSPHERE
#include "res://addons/time-of-day/src/sky/shaders/common/tod_sky_variables.gdshaderinc"
#include "tod_atmosphere_common.gdshaderinc"
#include "res://addons/time-of-day/src/sky/shaders/common/tod_color_include.gdshaderinc"

// Rayleigh.
uniform float tod_atm_sunE;
uniform float tod_atm_darkness;
uniform float tod_atm_thickness;
uniform float tod_atm_rayleigh_level;
uniform vec4 tod_atm_tint: source_color;
//uniform vec4 tod_atm_horizon_light_tint: source_color;
uniform vec4 tod_atm_night_tint: source_color;
uniform vec3 tod_atm_beta_ray;

// Mie.
uniform vec3 tod_atm_beta_mie;
uniform vec4 tod_atm_sun_mie_tint: source_color;
uniform float tod_atm_sun_mie_intensity;
uniform vec3 tod_atm_sun_partial_mie_phase;
uniform vec4 tod_atm_moon_mie_tint: source_color;
uniform float tod_atm_moon_mie_intensity;
uniform vec3 tod_atm_moon_partial_mie_phase;
uniform vec4 tod_atm_ground_color: source_color;
uniform float tod_sun_uMuS;

const float RAYLEIGH_ZENITH_LENGTH = 8.4e3;
const float MIE_ZENITH_LENGTH = 1.25e3;

void opticalDepth(float y, out vec3 sr, out vec3 sm){
	vec3 zenith = max(0.03, y + 0.03) + (max(0.0, -y) * tod_atm_ground_color.xyz);
	zenith = 1.0 / zenith;
	sr = vec3(zenith * RAYLEIGH_ZENITH_LENGTH * tod_atm_rayleigh_level);
	sm = vec3(zenith * MIE_ZENITH_LENGTH);
}

vec3 atmosphericScattering(vec3 pos,vec3 horizonBlend){
	vec3 scatter = vec3(0.0);
	float sunMus = tod_sun_uMuS - 0.6;
	float sunset = mix(sunMus, sunMus * 0.05, tod_atm_thickness - 1.0);
	sunset = saturate(sunset);
	
	vec3 sr, sm;
	
	opticalDepth(pos.y+tod_horizon_level, sr, sm);
	vec3 betaMie = tod_atm_beta_mie;
	vec3 betaRay = tod_atm_beta_ray * tod_atm_thickness;
	
	vec3 extinction = saturate(exp(-betaRay * sr + betaMie * sm));
	vec3 extincH = (1.0 -(extinction*0.75)) * sr * 0.00002;
	vec3 finalExtc = mix((1.0-extinction), extinction * extincH, 1.0-sunset);
	
	float sunMu = dot(tod_sun_direction, pos);
	float rayleighPhase = rayleighPhase(sunMu);
	
	vec3 BRT = betaRay * rayleighPhase;
	vec3 BMT = betaMie * miePhasePartial(
		sunMu, tod_atm_sun_partial_mie_phase) * horizonBlend;
	BMT *= tod_atm_sun_mie_intensity * tod_atm_sun_mie_tint.rgb;
	vec3 BRMT = (BRT+BMT) / (betaRay + betaMie); 
	BRMT = mix(BRMT, BRMT * (1.0 - extinction), tod_atm_darkness);
	
	vec3 Lin = tod_atm_sunE * (BRMT * finalExtc)  * tod_sun_uMuS;
	Lin *= tod_atm_tint.rgb;
	
	// Night
	float moonMu = dot(tod_moon_direction, pos);
	vec3 nLin = (1.0 - extinction) * tod_atm_night_tint.rgb;
	nLin += miePhasePartial(moonMu, tod_atm_moon_partial_mie_phase) 
		* tod_atm_moon_mie_tint.rgb * tod_atm_moon_mie_intensity * horizonBlend;
	
	scatter = Lin + nLin;
	return scatter;
}
#endif