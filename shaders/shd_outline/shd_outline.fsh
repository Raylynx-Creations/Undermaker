//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float pixel_width;
uniform float pixel_height;
uniform float outline_alpha;

void main()
{
    gl_FragColor = v_vColour * texture2D( gm_BaseTexture, v_vTexcoord );
	
	vec2 offset_x;
	offset_x.x = pixel_width;
	vec2 offset_y;
	offset_y.y = pixel_height;
	
	float alpha = gl_FragColor.a;
	if (alpha == 0.0){
		alpha += ceil(texture2D(gm_BaseTexture, v_vTexcoord + offset_x).a);
		alpha += ceil(texture2D(gm_BaseTexture, v_vTexcoord - offset_x).a);
		alpha += ceil(texture2D(gm_BaseTexture, v_vTexcoord + offset_y).a);
		alpha += ceil(texture2D(gm_BaseTexture, v_vTexcoord - offset_y).a);
	
		gl_FragColor = vec4(0.0,0.0,0.0,alpha*outline_alpha);
	}
}
