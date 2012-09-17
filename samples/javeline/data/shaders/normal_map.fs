precision mediump float;

varying vec2 samplePoint;
varying vec3 surfaceNormal;
varying vec3 surfaceTangent;
varying vec3 surfaceBitangent;

uniform sampler2D samplerDiffuse;
uniform sampler2D samplerDisplacement;
uniform sampler2D samplerNormal;
uniform vec3 lightDir;
uniform mat4 normalTransform;
uniform int mode;

vec3 standard() {
	vec3 BumpNorm = vec3(texture2D(samplerNormal, samplePoint));
	BumpNorm = (BumpNorm * 2.0) - 1.0;
	//vec3 norm = (normalTransform*vec4(BumpNorm, 0.0)).xyz;
	vec3 norm = (surfaceTangent * BumpNorm.x) + (surfaceBitangent * BumpNorm.y) + (surfaceNormal * BumpNorm.z);
	norm = normalize(norm);
	float NdotL = max(dot(norm, -lightDir), 0.0);
	vec3 ambientColor = vec3(0.3, 0.3, 0.3);
	vec3 diffuseColor = texture2D(samplerDiffuse, samplePoint * 1.0).xyz * NdotL;
	vec3 finalColor = diffuseColor + ambientColor;
	return finalColor;
	//return vec3(1.0, 1.0, 1.0);
}

vec3 basic() {
	float NdotL = max(dot(surfaceNormal, -lightDir), 0.0);
	vec3 ambientColor = vec3(0.3, 0.3, 0.3);
	vec3 diffuseColor = texture2D(samplerDiffuse, samplePoint * 1.0).xyz * NdotL;
	vec3 finalColor = diffuseColor + ambientColor;
	return finalColor;
	//return vec3(1.0, 1.0, 0.0);
}

vec3 ambient() {
	vec3 ambientColor = vec3(0.3, 0.3, 0.3);
	return ambientColor;

}
void main() {
	if (mode == 0) {
		gl_FragColor = vec4(basic(), 1.0);
	} else if (mode == 1) {
		gl_FragColor = vec4(standard(), 1.0);
	}
}