// Vertex attributes
attribute vec3 vPosition;
attribute vec3 vNormal;
attribute vec3 vTangent;
attribute vec3 vBitangent;
attribute vec2 vTexCoord0;

// Uniform variables
uniform float uTime;
uniform mat4 uViewMatrix;
uniform mat4 uModelMatrix;
uniform mat4 uModelViewMatrix;
uniform mat4 uModelViewProjectionMatrix;
uniform mat4 uProjectionMatrix;
uniform mat4 uNormalMatrix;

// Constants
vec3 lightPos = vec3(3.0, 3.0, 3.0);

// Varying variables
// Allows communication between vertex and fragment stages
varying vec2 texCoord;
varying vec3 tangentLightDir;
varying vec3 tangentEyeDir;

void main(void) {
  vec4 position4 = uModelViewMatrix * vec4(vPosition, 1.0);
  gl_Position = uModelViewProjectionMatrix * vec4(vPosition, 1.0);
  texCoord = vTexCoord0;

  mat3 normalMatrix = mat3(uNormalMatrix);
  vec3 n = normalize(vNormal * normalMatrix);
  vec3 t = normalize(vTangent * normalMatrix);
  vec3 b = normalize(vBitangent * normalMatrix);
  //vec3 b = cross (n, t);

  mat3 tbnMat = mat3(t.x, b.x, n.x,
                     t.y, b.y, n.y,
                     t.z, b.z, n.z);

  vec3 lightDir = lightPos - position4.xyz;
  tangentLightDir = lightDir * tbnMat;

  vec3 eyeDir = normalize(-position4.xyz);
  tangentEyeDir = eyeDir * tbnMat;
}
