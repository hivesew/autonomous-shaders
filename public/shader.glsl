precision mediump float;

uniform vec2 u_resolution;
uniform float u_time;

// Helper function for rotation
mat2 rotate(float a) {
    float s = sin(a);
    float c = cos(a);
    return mat2(c, -s, s, c);
}

// Pseudo-random number generator
float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void main() {
    vec2 uv = (gl_FragCoord.xy * 2.0 - u_resolution.xy) / u_resolution.y;
    vec2 original_uv = uv;

    // Swirling vortex effect
    float angle = atan(uv.y, uv.x);
    float radius = length(uv);
    uv = rotate(radius * 2.0 + u_time * 0.5) * uv;

    // Fractal-like blooming flower
    float t = u_time * 0.2;
    uv *= rotate(t);
    uv *= 2.5; // Zoom in

    for (int i = 0; i < 8; i++) {
        uv = abs(uv) / dot(uv, uv) - vec2(0.5, 0.4);
        uv *= rotate(t * 0.3);
    }

    // Final color calculation
    float d = length(uv);
    vec3 col = vec3(0.0);

    // Pulsating cosmic light
    float pulse = sin(u_time * 2.0 + radius * 4.0) * 0.5 + 0.5;

    // Combine colors based on patterns
    col += vec3(d * 0.2, d * 0.3, d * 0.5) * pulse;
    col += vec3(0.8, 0.5, 0.3) * (1.0 - d) * (1.0 - pulse);

    // Add iridescent particles (stars)
    float stars = 0.0;
    float star_density = 0.995;
    if (rand(original_uv * 100.0) > star_density) {
        stars = 1.0;
    }
    col += vec3(stars * pulse);


    gl_FragColor = vec4(col, 1.0);
}
