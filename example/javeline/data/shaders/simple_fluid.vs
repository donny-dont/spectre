precision highp float;

attribute vec3 vPosition;
attribute vec3 vNormal;

uniform mat4 projectionViewTransform;
uniform mat4 projectionTransform;
uniform mat4 viewTransform;
uniform mat4 normalTransform;

varying vec3 surfaceNormal;

void main() {
    vec4 vPosition4 = vec4(vPosition.x, vPosition.y, vPosition.z, 1.0);
    mat4 M = projectionViewTransform;
    surfaceNormal = (normalTransform*vec4(vNormal, 0.0)).xyz;
    gl_Position = M*vPosition4;
}
