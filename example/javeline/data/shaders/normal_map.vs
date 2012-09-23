precision highp float;

attribute vec3 vPosition;
attribute vec2 vTexCoord;
attribute vec3 vNormal;
attribute vec3 vBitangent;
attribute vec3 vTangent;

uniform mat4 projectionViewTransform;
uniform mat4 projectionTransform;
uniform mat4 viewTransform;
uniform mat4 normalTransform;
uniform mat4 objectTransform;

varying vec2 samplePoint;
varying vec3 surfaceNormal;
varying vec3 surfaceTangent;
varying vec3 surfaceBitangent;

void main() {
    surfaceNormal = (normalTransform*vec4(vNormal, 0.0)).xyz;
    surfaceTangent = (normalTransform*vec4(vTangent, 0.0)).xyz;
    surfaceBitangent = (normalTransform*vec4(vBitangent, 0.0)).xyz;
    vec4 vPosition4 = vec4(vPosition.x, vPosition.y, vPosition.z, 1.0);
    gl_Position = projectionViewTransform*vPosition4;
    samplePoint = vTexCoord;
}
