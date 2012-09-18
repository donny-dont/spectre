precision highp float;

attribute vec3 vPosition;
attribute vec3 vNormal;
attribute vec2 vTexCoord;

uniform mat4 projectionViewTransform;
uniform mat4 projectionTransform;
uniform mat4 viewTransform;
uniform mat4 normalTransform;
uniform mat4 objectTransform;

varying vec3 surfaceNormal;
varying vec2 samplePoint;
void main() {
	// TexCoord
	samplePoint = vTexCoord;
    // Normal
    surfaceNormal = (normalTransform*vec4(vNormal, 0.0)).xyz;
    // Position
    vec4 vPosition4 = vec4(vPosition.x, vPosition.y, vPosition.z, 1.0);
    mat4 M = projectionViewTransform*objectTransform;
    gl_Position = M*vPosition4;
}
