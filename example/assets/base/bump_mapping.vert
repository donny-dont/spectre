precision highp float;

// Vertex attributes
attribute vec3 vPosition;
attribute vec3 vNormal;
attribute vec3 vTangent;
attribute vec3 vBinormal;
attribute vec2 vTexCoord0;

// Uniform variables
uniform float uTime;
uniform mat4 uModelMatrix;
uniform mat4 uModelViewMatrix;
uniform mat4 uModelViewProjectionMatrix;
uniform mat4 uProjectionMatrix;
uniform mat4 uNormalMatrix;

// Constants
vec3 lightPosition = vec3(1.0, 0.0, 0.0);

// Varying variables
// Allows communication between vertex and fragment stages
varying vec3 lightDir;
varying vec2 texCoord;
varying vec3 viewDir;

void main()
{
    // Transform normal and tangent to eye space
    vec3 norm = normalize(mat3(uNormalMatrix) * vNormal);
    vec3 tang = normalize(mat3(uNormalMatrix) * vTangent);
    
    // Compute the binormal
    vec3 binormal = vBinormal;//cross(norm, tang);

    // Matrix for transformation to tangent space
    mat3 toObjectLocal = mat3(
        tang.x, binormal.x, norm.x,
        tang.y, binormal.y, norm.y,
        tang.z, binormal.z, norm.z ) ;

    // Transform light direction and view direction to tangent space
    vec3 pos = vec3(uModelViewMatrix * vec4(vPosition,1.0));
    lightDir = normalize(toObjectLocal * (lightPosition - pos));

    viewDir = toObjectLocal * normalize(-pos);

    texCoord = vTexCoord0;

    gl_Position = uModelViewProjectionMatrix * vec4(vPosition,1.0);
}
