precision mediump float;

uniform sampler2D sampler;
varying vec3 particleColor;
varying vec2 texcoord;

void main() {
	vec4 tc = texture2D(sampler, texcoord).xyzw;
	//tc *= vec4(particleColor, 1.0);
    gl_FragColor = tc;
}