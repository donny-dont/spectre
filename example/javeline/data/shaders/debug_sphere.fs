precision mediump float;

uniform vec4 debugSphereColor;

void main() {
    gl_FragColor = debugSphereColor.rgba;
}