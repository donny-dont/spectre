precision highp float;

attribute vec3 vPosition;
attribute vec3 vNormal;

varying vec3 fNormal;

uniform mat4 objectTransform;
uniform mat3 objectRotation;
uniform vec3 objectTranslation;

uniform mat4 cameraTransform;
uniform mat3 cameraRotation;
uniform vec3 cameraTranslation;

uniform mat4 viewTransform;

void main() {
    vec4 vPosition4 = vec4(vPosition.x, vPosition.y, vPosition.z, 1.0);
    fNormal = objectRotation*vNormal;
    //gl_Position = vec4(0.0, 0.0, 0.0, 1.0);
    gl_Position = (viewTransform*objectTransform)*vPosition4;
    //gl_Position = objectTransform*(cameraTransform*(viewProjection*vPosition4));
}
