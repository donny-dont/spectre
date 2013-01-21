attribute vec3 POSITION;
attribute vec3 TEXCOORD0;
uniform mat4 cameraTransform;

varying vec3 samplePoint;

void main(void)
{
	vec4 vPosition4 = vec4(POSITION.x*512.0,
			       POSITION.y*512.0,
			       POSITION.z*512.0,
			       1.0);
	gl_Position = cameraTransform*vPosition4;
	samplePoint = TEXCOORD0;
}
