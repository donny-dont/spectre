precision mediump float;

varying vec3 surfaceNormal;
varying vec2 samplePoint;

varying vec3 lightDir;

uniform sampler2D diffuse;

void main() {
	vec3 normal = normalize(surfaceNormal);
	vec3 light = normalize(lightDir);
	float NdotL = max(dot(normal, -light), 0.3);
	vec3 ambientColor = vec3(0.1, 0.1, 0.1);
	//vec3 diffuseColor = vec3(1.0, 0.0, 0.0) * NdotL;
	vec3 diffuseColor = vec3(texture2D(diffuse, samplePoint)) * NdotL;
	vec3 finalColor = diffuseColor + ambientColor;
    //gl_FragColor = vec4(NdotL, NdotL, 1.0, 1.0);
    gl_FragColor = vec4(finalColor, 1.0);
}