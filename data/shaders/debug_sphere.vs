precision highp float;

// Input attributes
attribute vec3 vPosition;

// Input uniforms
uniform mat4 cameraTransform;
uniform vec4 debugSphereCenterAndRadius;

void main() {
    vec3 center = debugSphereCenterAndRadius.xyz;
    float scale = debugSphereCenterAndRadius.w;
    vec4 vPosition4 = vec4((vPosition * scale) + center, 1.0);
    gl_Position = cameraTransform*vPosition4;
}