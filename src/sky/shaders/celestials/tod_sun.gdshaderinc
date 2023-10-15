#ifndef TOD_SUN
#define TOD_SUN

float sunDisk(vec3 pos, vec3 dir, lowp float size){
	mediump float ret = 0.0;
#ifdef HIGH_QUALITY_SUN_DISK
	ret = (pow(2.0- (2.0 * dot(dir, pos)), -1.5) * size*0.001);
#else
	ret = 1.0 - step(size, length(pos - dir));
#endif
	ret = min(50.0, ret); // Prevent reflection artifacts.
	
	return ret;
}

float sunDisk2(float mu, float size){
	return (pow(2.0- (2.0 * mu), -1.5) * size * size);
}

#endif