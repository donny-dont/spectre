precision highp float;
varying vec3 samplePoint;
uniform samplerCube skyMap;

void main(void)
{
	vec4 color = textureCube(skyMap, samplePoint);
	//gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
	gl_FragColor = vec4(color.xyz, 1.0);
}
