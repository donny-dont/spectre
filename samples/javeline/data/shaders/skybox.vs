precision highp float;

attribute vec3 vPosition;
attribute vec2 vTexCoord;

uniform mat4 cameraTransform;

varying vec2 samplePoint;

void main() {
    vec4 vPosition4 = vec4(vPosition.x, vPosition.y, vPosition.z, 1.0);
    gl_Position = cameraTransform*vPosition4;
    //gl_Position = vec4(vPosition.x, vPosition.y, vPosition.z, 1.0);
    samplePoint = vTexCoord;
}
