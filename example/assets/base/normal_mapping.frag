precision highp float;

// Varying variables
// Allows communication between vertex and fragment stages
varying vec2 texCoord;
varying vec3 tangentLightDir;
varying vec3 tangentEyeDir;

// Uniforms
uniform sampler2D uDiffuseSampler;
uniform sampler2D uNormalSampler;

// Constants
vec3 ambientLight = vec3(0.2, 0.2, 0.2);
vec3 lightColor = vec3(1.0, 1.0, 1.0);
vec3 specularColor = vec3(1.0, 1.0, 1.0);
float shininess = 8.0;

void main(void) {
  vec3 lightDir = normalize(tangentLightDir);
  vec3 normal = normalize(2.0 * (texture2D(uNormalSampler, texCoord.st).rgb - 0.5));
  vec4 diffuseColor = texture2D(uDiffuseSampler, texCoord.st);

  float specularLevel = 1.0;
  
  vec3 eyeDir = normalize(tangentEyeDir);
  vec3 reflectDir = reflect(-lightDir, normal);
  float specularFactor = pow(clamp(dot(reflectDir, eyeDir), 0.0, 1.0), shininess) * specularLevel;

  float lightFactor = max(dot(lightDir, normal), 0.0);
  vec3 lightValue = ambientLight + (lightColor * lightFactor) + (specularColor * specularFactor);

  gl_FragColor = vec4(diffuseColor.rgb * lightValue, diffuseColor.a);
}
