precision highp float;

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
vec4 lightDirection = vec4(0.0, 0.0, 1.0, 0.0);

// Varying variables
// Allows communication between vertex and fragment stages
varying vec2 texCoord;
varying vec3 lightVec;
varying vec3 halfVec;
varying vec3 eyeVec;

void main()
{
  texCoord =  vTexCoord0;

  // Building the matrix Eye Space -> Tangent Space
  vec3 n = normalize(mat3(uNormalMatrix) * vNormal);
  vec3 t = normalize(mat3(uNormalMatrix) * vTangent);
  vec3 b = normalize(mat3(uNormalMatrix) * vBitangent);
  
  mat3 tbnMatrix = mat3(t.x, b.x, n.x,
                        t.y, b.y, n.y,
                        t.z, b.z, n.z);

  vec3 vertexPosition = vec3(uModelViewMatrix * vec4(vPosition, 1.0));
  vec3 lightDir = vec3(uViewMatrix * -lightDirection);
  //vec3 lightDir = normalize(lightDirection.xyz - vertexPosition);

  // transform light and half angle vectors by tangent basis
  lightVec = normalize(tbnMatrix * lightDir);
  eyeVec = normalize(tbnMatrix * vertexPosition);

  vertexPosition = normalize(vertexPosition);

  /* Normalize the halfVector to pass it to the fragment shader */

  // No need to divide by two, the result is normalized anyway.
  // vec3 halfVector = normalize((vertexPosition + lightDir) / 2.0);
  vec3 halfVector = normalize(vertexPosition + lightDir);

  // No need to normalize, t,b,n and halfVector are normal vectors.
  //normalize (v);
  halfVec = tbnMatrix * halfVector;

  gl_Position = uModelViewProjectionMatrix * vec4(vPosition,1.0);
}
