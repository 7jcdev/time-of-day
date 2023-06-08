shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley;
//specular_schlick_ggx;

// Textures.
group_uniforms Textures;
uniform sampler2D _albedo: source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D _normal_map: hint_roughness_normal,filter_linear_mipmap,repeat_enable;
uniform vec4 _color1: source_color;

uniform vec2 _uv_tile = vec2(1.0, 1.0);
uniform float _roughtness: hint_range(0.0, 1.0) = 1.0;
uniform float _height_detail_level: hint_range(0.0, 100.0) = 2.7;

group_uniforms heightmap;
uniform sampler2D _heightmap: repeat_enable;

uniform float _height: hint_range(0.0, 1000) = 1.0;

uniform float _height_uv_tile_x = 1.0;
uniform float _height_uv_tile_y = 1.0;

uniform float _height_uv_offset_x: hint_range(-100, 100, 0.0010000000475);
uniform float _height_uv_offset_y: hint_range(-100, 100, 0.0010000000475);

group_uniforms Normals;
uniform float _normal_darkness: hint_range(0.05, 100.0) = 1.0;

vec3 unpackNormal(in vec3 col){
	col = col.xyz * 2.0 - 1.0;
	col.z *= -1.0;
	return col;
}

float getHeight(vec2 uv){
	float c =(texture(_heightmap, uv.xy) * _height).r;
	return c;
}

vec3 getNormal(in float height, in vec2 uv){
	return normalize(
		vec3(height - getHeight(uv + vec2(0.001, 0.0)), 0.01*_normal_darkness, height - getHeight(uv + vec2(0.0, 0.001)))
	);
}

vec3 getFragmentNormal(mat4 viewMatrix, in vec2 uv){
	return (mat3(viewMatrix) * getNormal(getHeight(uv), uv));
}

varying vec3 v_vert;
varying vec2 v_uv;
void vertex(){
	v_vert = VERTEX;
	v_uv = v_vert.xz + vec2(_height_uv_offset_x, _height_uv_offset_y) + 0.5;
	v_uv *= vec2(_height_uv_tile_x, _height_uv_tile_y);
	
	float h = getHeight(v_uv);
	v_vert.y = h;
	
	NORMAL = getNormal(h, v_uv);
	VERTEX = v_vert;
}

void fragment(){
	
	//float yy = clamp((v_vert.y * 5.0) -_height_detail_level*5.0, 0.0, 1.0);
	//ALBEDO = vec3(0.5);
	ALBEDO = texture(_albedo, v_uv* _uv_tile.xy).rgb * _color1.rgb;
	//ALBEDO = mix(ALBEDO, texture(_albedo2, v_uv * _uv_tile.xy).rgb * _color2.rgb,yy);
	ROUGHNESS = _roughtness;
	NORMAL_MAP = texture(_normal_map, v_uv * _uv_tile).rgb; //mix(texture(_normal_map, v_uv * _uv_tile).rgb, texture(_normal_map2, v_uv * _uv_tile).rgb, yy);
	//NORMAL = getFragmentNormal(VIEW_MATRIX, v_uv);
}