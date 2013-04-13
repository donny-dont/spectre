precision mediump float;

// Varying variables
// Allows communication between vertex and fragment stages
varying vec2 texCoord;
varying vec3 lightVec;
varying vec3 halfVec;
varying vec3 eyeVec;

// Constants
vec4 ka = vec4(0.2, 0.2, 0.2, 1.0);
vec4 kd = vec4(0.6, 0.6, 0.6, 1.0);
vec4 ks = vec4(0.4, 0.4, 0.4, 1.0);

// Uniforms
uniform sampler2D uDiffuseSampler;
uniform sampler2D uNormalSampler;

void main()
{
	// lookup normal from normal map, move from [0,1] to  [-1, 1] range, normalize
	vec3 normal = 2.0 * texture2D(uNormalSampler, texCoord).rgb - 1.0;
	normal = normalize(normal);
	
	// compute diffuse lighting
	float lambertFactor = max(dot(lightVec, normal), 0.0) ;
	vec4 diffuseMaterial = vec4(0.0);
	vec4 diffuseLight = vec4(0.0);
	
	// compute specular lighting
	vec4 specularMaterial;
	vec4 specularLight;
	float shininess;
  
	// compute ambient
	vec4 ambientLight = ka;	
	
	if (lambertFactor > 0.0)
	{
		diffuseMaterial = texture2D(uDiffuseSampler, texCoord);
		diffuseMaterial = vec4(0.6, 0.6, 0.6, 1.0);
		diffuseLight = kd;
		
		// In doom3, specular value comes from a texture 
		specularMaterial = vec4(1.0);
		specularLight = ks;
		shininess = pow(max(dot(halfVec, normal), 0.0), 2.0);
		 
		gl_FragColor =	diffuseMaterial * diffuseLight * lambertFactor ;
		gl_FragColor +=	specularMaterial * specularLight * shininess ;					
	}
	
	gl_FragColor +=	ambientLight;
}			
