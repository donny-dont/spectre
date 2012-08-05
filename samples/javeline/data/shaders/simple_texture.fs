precision mediump float;

varying vec2 samplePoint;
uniform sampler2D sampler;

void main() {
    gl_FragColor = texture2D(sampler, samplePoint * 1.0);
}