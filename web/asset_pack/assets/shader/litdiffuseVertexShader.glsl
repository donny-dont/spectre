precision highp float;

attribute vec3 POSITION;
attribute vec3 NORMAL;
attribute vec2 TEXCOORD0;

uniform mat4 cameraTransform;
uniform mat4 normalTransform;
uniform mat4 objectTransform;

uniform vec3 lightDirection;

varying vec3 surfaceNormal;
varying vec2 samplePoint;
varying vec3 lightDir;

void main() {
    // TexCoord
    samplePoint = TEXCOORD0;
    // Normal
    //mat4 LM = normalTransform*objectTransform;
    vec3 N = (objectTransform*vec4(NORMAL, 0.0)).xyz;
    N = normalize(N);
    N = (normalTransform*vec4(N, 0.0)).xyz;
    surfaceNormal = normalize(N);
    lightDir = (normalTransform*vec4(lightDirection, 0.0)).xyz;
    vec4 vPosition4 = vec4(POSITION.x, POSITION.y, POSITION.z, 1.0);
    //mat4 M = cameraTransform*objectTransform;
    mat4 M = cameraTransform;
    gl_Position = M*vPosition4;
}
