precision mediump float;

varying vec3 particleColor;
uniform sampler2D sampler;

void main() {
	vec4 tc = texture2D(sampler, gl_PointCoord).xyzw;
	tc *= vec4(particleColor, 1.0);
    gl_FragColor = tc;
}