precision mediump float;

//---------------------------------------------------------------------
// Varying variables
//
// Allows communication between vertex and fragment stages
//---------------------------------------------------------------------

/// The postition of the vertex.
varying vec3 position;
/// The normal of the model.
varying vec3 normal;

//---------------------------------------------------------------------
// Constants
//---------------------------------------------------------------------

/// The position of the light.
vec3 lightPosition = vec3(1.0, 1.0, 0.0);
/// The intensity of the light.
vec3 lightIntensity = vec3(0.5, 0.5, 0.5);

/// The diffuse color.
vec3 kd = vec3(0.5, 0.5, 0.5);
/// The ambient color.
vec3 ka = vec3(0.2, 0.2, 0.2);
/// The specular color.
vec3 ks = vec3(0.6, 0.6, 0.6);

float shininess = 64.0;

/// Computes the lighting.
vec3 ads() {
  vec3 n = normalize(normal);
  vec3 s = normalize(lightPosition - position);
  vec3 v = normalize(-position);
  vec3 r = reflect(-s, n);

  return lightIntensity * 
    (ka +
     kd * max(dot(s, n), 0.0) +
     ks * pow(max(dot(r, v), 0.0), shininess));
}

void main()
{
  gl_FragColor = vec4(ads(), 1.0);
}
