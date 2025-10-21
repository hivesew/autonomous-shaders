precision mediump float;

// Uniforms are provided by the script but unused in this simple shader.
uniform vec2 u_resolution;
uniform float u_time;

void main() {
    // Set every pixel to white (R=1.0, G=1.0, B=1.0) with full opacity (A=1.0).
    gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);
}