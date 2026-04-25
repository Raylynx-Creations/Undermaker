//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D mask_texture;
uniform vec2 resolution;
uniform bool inverse;

void main()
{
    vec4 base = texture2D(gm_BaseTexture, v_vTexcoord);

    vec2 screen_uv = gl_FragCoord.xy / resolution;
    vec4 mask = texture2D(mask_texture, screen_uv);

	if (inverse){
		base.a *= 1.0 - mask.a;
	}else{
		base.a *= mask.a;
	}

    gl_FragColor = base * v_vColour;
}
