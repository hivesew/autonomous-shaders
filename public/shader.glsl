#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform float u_time;

// 2D Random function
float random (vec2 st) {
    return fract(sin(dot(st.xy,
                         vec2(12.9898,78.233)))*
        43758.5453123);
}

// 2D Noise function
float noise (vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);

    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));

    vec2 u = f*f*(3.0-2.0*f);
    return mix(a, b, u.x) +
            (c - a)* u.y * (1.0 - u.x) +
            (d - b) * u.x * u.y;
}

// Function to create a swirling motion
vec2 swirl(vec2 uv, float time) {
    float angle = 0.5 * sin(time * 0.5) + length(uv) * 2.0;
    float r = length(uv);
    uv = vec2(uv.x * cos(angle) - uv.y * sin(angle),
              uv.x * sin(angle) + uv.y * cos(angle));
    return uv;
}

// Function to create a crystalline structure
float crystal(vec2 uv, float time) {
    uv = abs(uv);
    uv = mod(uv * 5.0 + time * 0.2, 1.0);
    float d = length(uv - 0.5);
    return smoothstep(0.1, 0.0, d) * (sin(time * 3.0) * 0.5 + 0.5);
}

// Function for holographic waves
vec3 waves(vec2 uv, float time) {
    float wave = sin(uv.x * 10.0 + time * 2.0) * cos(uv.y * 10.0 + time * 2.0);
    vec3 col = vec3(0.5 + 0.5 * sin(wave * 5.0 + time),
                    0.5 + 0.5 * cos(wave * 5.0 + time + 2.0),
                    0.5 + 0.5 * sin(wave * 5.0 + time + 4.0));
    return col;
}


void main() {
    vec2 uv = (gl_FragCoord.xy * 2.0 - u_resolution.xy) / u_resolution.y;
    float time = u_time * 0.5;

    // --- Swirling Vortex of Particles ---
    vec2 swirl_uv = swirl(uv, time);
    float n = noise(swirl_uv * 5.0);
    vec3 particle_color = vec3(n * 0.8, n * 0.5, n * 1.0) * (1.0 - length(uv));

    // --- Pulsating Crystalline Structure ---
    float pulse = sin(time * 2.0) * 0.5 + 0.5;
    float c = crystal(uv, time) * pulse;
    vec3 crystal_color = vec3(0.2, 0.5, 1.0) * c;

    // --- Fracturing and Dissolving ---
    float fracture_noise = noise(uv * 3.0 + time * 0.3);
    float fracture_effect = smoothstep(0.4, 0.6, fracture_noise + (1.0 - pulse) * 0.5);

    // --- Shimmering Holographic Waves ---
    vec3 wave_color = waves(uv, time) * (1.0 - length(uv)) * 0.3;

    // --- Combine the effects ---
    vec3 final_color = mix(particle_color, crystal_color, smoothstep(0.1, 0.5, c));
    final_color = mix(final_color, wave_color, fracture_effect);

    // Add some shimmering highlights
    float shimmer = noise(uv * 10.0 + time * 5.0);
    if (shimmer > 0.95) {
        final_color += vec3(0.8, 0.8, 1.0);
    }


    gl_FragColor = vec4(final_color, 1.0);
}
