//---------------------------------------------------------------------
// Vertex attributes
//---------------------------------------------------------------------

/// The vertex position.
attribute vec3 vPosition;
/// The texture coordinate.
attribute vec2 vTexCoord0;
/// The vertex normal.
attribute vec3 vNormal;

//---------------------------------------------------------------------
// Uniform variables
//---------------------------------------------------------------------

/// The Model-View matrix.
uniform mat4 uModelViewMatrix;
/// The Model-View-Projection matrix.
uniform mat4 uModelViewProjectionMatrix;
/// The normal matrix
uniform mat4 uNormalMatrix;

//---------------------------------------------------------------------
// Varying variables
//
// Allows communication between vertex and fragment stages
//---------------------------------------------------------------------

/// The postition of the vertex.
varying vec3 position;
/// The texture coordinate of the vertex.
varying vec2 texCoord;
/// The normal of the model.
varying vec3 normal;

void main()
{
  vec4 vPosition4 = vec4(vPosition, 1.0);
  position = vec3(uModelViewMatrix * vPosition4);
  
  texCoord = vTexCoord0;
  
  normal = normalize(mat3(uNormalMatrix) * vNormal);
  
  gl_Position = uModelViewProjectionMatrix * vPosition4;
}
