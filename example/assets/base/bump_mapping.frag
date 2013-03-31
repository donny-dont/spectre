precision mediump float;

// Varying variables
// Allows communication between vertex and fragment stages
varying vec3 lightDir;
varying vec2 texCoord;
varying vec3 viewDir;

// Constants
vec3 lightIntensity = vec3(0.5, 0.5, 0.5);
vec3 ka = vec3(0.2, 0.2, 0.2);
vec3 ks = vec3(0.6, 0.6, 0.6);
float shininess = 16.0;

uniform sampler2D uDiffuseSampler;
uniform sampler2D uNormalSampler;

vec3 phongModel(vec3 norm, vec3 diffR) {
  vec3 r = reflect(-lightDir, norm);
  vec3 ambient = lightIntensity * ka;
  float sDotN = max(dot(lightDir, norm), 0.0);
  vec3 diffuse = lightIntensity * diffR * sDotN;

  vec3 spec = vec3(0.0);
  if( sDotN > 0.0 ) {
    spec = lightIntensity * ks *
           pow(max(dot(r, viewDir), 0.0), shininess);
  }

  return ambient + diffuse;// + spec;
}

void main() {
  // Lookup the normal from the normal map
  vec4 normal = texture2D(uNormalSampler, texCoord);
  vec4 texColor = vec4(0.6, 0.6, 0.6, 1.0);//texture2D(uDiffuseSampler, texCoord);

  gl_FragColor = vec4(phongModel(normal.xyz, texColor.rgb), 1.0);
}
