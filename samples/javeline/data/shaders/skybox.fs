precision mediump float;

varying vec2 samplePoint;
uniform sampler2D sampler1;
uniform sampler2D sampler2;
uniform float t;

void main() {
    vec4 s1 = texture2D(sampler1, samplePoint);
    vec4 s2 = texture2D(sampler2, samplePoint);
    gl_FragColor = s1 * (1.0-t) + (t * s2);
}