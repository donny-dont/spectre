precision mediump float;

// Varying variables
// Allows communication between vertex and fragment stages
varying vec3 position;
varying vec2 texCoord;
varying vec3 normal;

// Uniforms
uniform sampler2D sampler0;

// Constants
vec3 lightPosition = vec3(0.0, 0.0, 1.0);
vec3 lightIntensity = vec3(0.5, 0.5, 0.5);
vec3 kd;
vec3 ka = vec3(0.2, 0.2, 0.2);
vec3 ks = vec3(0.6, 0.6, 0.6);
float shininess = 64.0;

vec3 ads() {
  vec3 n = normalize(normal);
  vec3 s = normalize(lightPosition);
  vec3 v = normalize(-position);
  vec3 r = reflect(-s, n);

  return lightIntensity * 
    (ka +
     kd * max(dot(s, n), 0.0) +
     ks * pow(max(dot(r, v), 0.0), shininess));
}

void main() {
  kd = texture2D(sampler0, texCoord).xyz;
  gl_FragColor = vec4(ads(), 1.0);
}
