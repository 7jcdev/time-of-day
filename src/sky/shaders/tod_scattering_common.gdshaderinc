#ifndef TOD_SCATTERING_INCLUDE
#define TOD_SCATTERING_INCLUDE

#include "tod_sky_common.gdshaderinc"

float rayleighPhase(float mu){
	return k3PI16 * (1.0 + mu * mu);
}

float miePhasePartial(float mu, vec3 partial){
	return kPI4 * partial.x * (pow(partial.y - partial.z * mu, -1.5));
}

float miePhase(float mu, float g){
	float g2 = g*g;
	return kPI4 * ((1.0 - g2) / (2.0 + g2)) * 
		(pow((1.0 + g2) - (2.0 * g) * mu, -1.5));
}

float miePhaseSimplified(float mu, float g){
	float g2 = g*g;
	return kPI4 * (1.0 - g2) * 
		(pow((1.0 + g2) - (2.0 * g) * mu, -1.5));
}

float sunDisk(float mu, float size){
	return (pow(2.0- (2.0 * mu), -1.5) * size * size);
}

float betaMie(float mie, float turbidity){
	const float k = 434e-6;
	return 1.0 * mie * turbidity * k;
}

#endif // Atmospheric Scattering Common.