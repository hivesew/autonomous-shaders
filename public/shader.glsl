precision mediump float;

uniform vec2 u_resolution;
uniform float u_time;

// Pseudo-random number generator
float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

// 2D noise function
float noise(vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);

    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));

    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.y * u.x;
}

void main() {
    vec2 st = gl_FragCoord.xy / u_resolution.xy;
    st.x *= u_resolution.x / u_resolution.y;

    vec2 to_center = vec2(0.5) - st;
    float angle = atan(to_center.y, to_center.x);
    float radius = length(to_center) * 2.0;

    float n = noise(vec2(angle * 3.0, radius * 4.0 + u_time * 0.2));
    
    float vortex = fract(angle / (2.0 * 3.14159) + u_time * 0.1);
    float pattern = floor(vortex * 10.0 + n * 5.0) / 10.0;
    
    float r = sin(pattern * 15.0 + u_time * 0.5) * 0.5 + 0.5;
    float g = sin(pattern * 20.0 + u_time * 0.7) * 0.5 + 0.5;
    float b = sin(pattern * 25.0 + u_time * 0.9) * 0.5 + 0.5;

    vec3 color = vec3(r, g, b);
    
    // Fade to black at the edges to create the abyss
    color *= (1.0 - radius * 0.8);

    gl_FragColor = vec4(color, 1.0);
}
