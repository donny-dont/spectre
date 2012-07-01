precision highp float;

// Input attributes
attribute vec3 vPosition;
attribute vec4 vColor;
// Input uniforms
uniform mat4 cameraTransform;
// Varying outputs
varying vec4 fColor;

void main() {
    fColor = vColor;
    vec4 vPosition4 = vec4(vPosition.x, vPosition.y, vPosition.z, 1.0);
    gl_Position = cameraTransform*vPosition4;
}