precision mediump float;

uniform vec2 u_resolution;
uniform float u_time;

// 2D Random
float random (in vec2 st) {
    return fract(sin(dot(st.xy,
                         vec2(12.9898,78.233)))
                 * 43758.5453123);
}

// 2D Noise based on Morgan McGuire @morgan3d
// https://www.shadertoy.com/view/4dS3Wd
float noise (in vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);

    // Four corners in 2D of a tile
    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));

    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(a, b, u.x) +
            (c - a)* u.y * (1.0 - u.x) +
            (d - b) * u.x * u.y;
}

mat2 rotate(float a) {
    float s = sin(a);
    float c = cos(a);
    return mat2(c, -s, s, c);
}

void main() {
    vec2 uv = (gl_FragCoord.xy * 2.0 - u_resolution.xy) / u_resolution.y;
    uv *= 1.5;

    // Swirling nebula background
    vec2 uv_nebula = uv;
    uv_nebula *= rotate(u_time * 0.1);
    float n = noise(uv_nebula * 2.0);
    vec3 nebula_color = vec3(0.1, 0.2, 0.5) * n;
    nebula_color += vec3(0.5, 0.2, 0.3) * noise(uv_nebula * 4.0);
    nebula_color *= sin(uv.x * 2.0 + u_time * 0.5) + 1.5;


    // Pulsating crystalline heart
    float pulse = (sin(u_time * 2.0) * 0.5 + 0.5) * 0.2 + 0.1;
    float crystal_dist = length(uv);
    float crystal = 1.0 - smoothstep(pulse, pulse + 0.05, crystal_dist);
    vec3 crystal_color = vec3(0.8, 0.8, 1.0) * crystal;

    // Fracturing shards
    vec2 uv_shards = uv;
    uv_shards *= rotate(u_time * 0.3);
    float shards = 0.0;
    for (int i = 0; i < 8; i++) {
        uv_shards.x += 0.2 * float(i) * sin(u_time * 0.1);
        shards += 0.005 / abs(sin(uv_shards.x * 10.0 + float(i) * 0.5) - uv_shards.y);
    }
    shards = pow(shards, 1.5);
    vec3 shards_color = vec3(0.9, 0.7, 0.3) * shards;


    vec3 color = nebula_color + crystal_color + shards_color;
    color = pow(color, vec3(0.8)); // Gamma correction

    gl_FragColor = vec4(color, 1.0);
}