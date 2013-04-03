precision highp float;

// Vertex attributes
attribute vec3 vPosition;
attribute vec3 vNormal;

// Uniform variables
uniform float uTime;
uniform mat4 uModelMatrix;
uniform mat4 uModelViewMatrix;
uniform mat4 uModelViewProjectionMatrix;
uniform mat4 uProjectionMatrix;
uniform mat4 uNormalMatrix;

// Varying variables
// Allows communication between vertex and fragment stages
varying vec3 position;
varying vec3 normal;

void main() {
  vec4 vPosition4 = vec4(vPosition, 1.0);
  position = vec3(uModelViewMatrix * vPosition4);
  normal = normalize(mat3(uNormalMatrix) * vNormal);
  gl_Position = uModelViewProjectionMatrix * vPosition4;
}
