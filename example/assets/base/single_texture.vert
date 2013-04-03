precision highp float;

// Vertex attributes
attribute vec3 vPosition;
attribute vec2 vTexCoord0;

// Uniform variables
uniform float uTime;
uniform mat4 uModelMatrix;
uniform mat4 uModelViewMatrix;
uniform mat4 uModelViewProjectionMatrix;
uniform mat4 uProjectionMatrix;
uniform mat4 uNormalMatrix;

// Varying variables
varying vec2 texCoord;

void main() {
  vec4 vPosition4 = vec4(vPosition, 1.0);
  texCoord = vTexCoord0;
  gl_Position = uModelViewProjectionMatrix * vPosition4;
}
