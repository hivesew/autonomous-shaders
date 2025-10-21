#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform float u_time;

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

mat2 rotate(float angle) {
    return mat2(cos(angle), -sin(angle), sin(angle), cos(angle));
}

void main() {
    vec2 st = gl_FragCoord.xy/u_resolution.xy;
    st.x *= u_resolution.x/u_resolution.y;

    vec3 color = vec3(0.0);
    vec2 pos = st - vec2(0.5);
    pos = rotate(u_time * 0.2) * pos;
    pos *= 3.0;

    float n = noise(pos * 10.0 + u_time * 0.5);
    float vortex = 1.0 / (length(pos) + 0.1) * 0.5;
    vortex += n;

    float crystal_time = mod(u_time, 10.0);
    float crystal_factor = smoothstep(2.0, 4.0, crystal_time) - smoothstep(6.0, 8.0, crystal_time);

    vec2 q = vec2(0.);
    q.x = noise(pos + vec2(0.0, u_time * 0.1));
    q.y = noise(pos + vec2(u_time * 0.1, 0.0));

    vec2 r = vec2(0.);
    r.x = noise(pos + q + vec2(1.7,9.2)+ 0.15*u_time );
    r.y = noise(pos + q + vec2(8.3,2.8)+ 0.126*u_time);

    float f = noise(pos+r);

    color = mix(color, vec3(0.1, 0.0, 0.2), clamp(f*vortex, 0.0, 1.0));
    color = mix(color, vec3(0.8, 0.5, 1.0), clamp(pow(f, 4.0) * crystal_factor, 0.0, 1.0));
    color = mix(color, vec3(1.0, 0.8, 0.9), clamp(pow(f, 6.0) * crystal_factor, 0.0, 1.0));

    float dissolve_factor = smoothstep(8.0, 10.0, crystal_time);
    float dust = random(st + fract(u_time));
    color = mix(color, vec3(0.9, 0.9, 1.0) * dust, dissolve_factor * step(0.99, dust));

    gl_FragColor = vec4(color,1.0);
}