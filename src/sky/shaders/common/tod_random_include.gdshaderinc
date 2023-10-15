#ifndef TOD_RANDOM_INCLUDE
#define TOD_RANDOM_INCLUDE

// Simple random from https://thebookofshaders.com/10/
float simpleRandom(vec2 st){
	return fract(sin(dot(st.xy, vec2(12.9898,78.233)))*43758.5453123);
}
#endif