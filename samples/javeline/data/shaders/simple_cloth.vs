precision highp float;

attribute vec3 vPosition;
attribute vec3 vColor;
attribute vec2 vTexCoord;

uniform mat4 projectionViewTransform;
uniform mat4 projectionTransform;
uniform mat4 viewTransform;
uniform mat4 normalTransform;

varying vec3 particleColor;
varying vec2 texcoord;

void main() {
    vec4 vPosition4 = vec4(vPosition.x, vPosition.y, vPosition.z, 1.0);
    mat4 M = projectionViewTransform;
    particleColor = vColor;
    texcoord = vTexCoord;
    gl_Position = M*vPosition4;
}
