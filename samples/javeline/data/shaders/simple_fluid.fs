precision mediump float;

varying vec3 surfaceNormal;
uniform vec3 lightDir;

void main() {
	vec3 normal = normalize(surfaceNormal);
	float NdotL = max(dot(normal, -lightDir), 0.0);

	vec3 ambientColor = vec3(0.0, 0.0, 1.0);
	vec3 diffuseColor = vec3(1.0, 1.0, 0.0) * NdotL;
	vec3 finalColor = diffuseColor + ambientColor;
    //gl_FragColor = vec4(NdotL, NdotL, 1.0, 1.0);
    gl_FragColor = vec4(finalColor, 1.0);
}