precision mediump float;
uniform vec2 u_resolution;
uniform float u_time;

void main() {
    vec2 uv = (gl_FragCoord.xy * 2.0 - u_resolution.xy) / u_resolution.y;
    float time = u_time * 0.1;
    
    // Rotate coordinates
    float angle = time;
    mat2 rotation = mat2(cos(angle), -sin(angle), sin(angle), cos(angle));
    uv = rotation * uv;
    
    // Create a swirling, fractal pattern
    vec3 color = vec3(0.0);
    float scale = 2.0;
    for (int i = 0; i < 8; i++) {
        uv = abs(uv) / dot(uv, uv) - scale;
        float d = length(uv);
        color += vec3(0.02 / d, 0.05 / d, 0.1 / d);
    }
    
    // Add a pulsing light effect
    float pulse = 0.5 + 0.5 * sin(u_time * 2.0);
    color *= pulse;
    
    // Add shimmering caustics
    vec2 p = gl_FragCoord.xy / u_resolution.xy;
    float caustics = 0.0;
    for (int i = 1; i <= 5; i++) {
        float fi = float(i);
        p += 0.1 * sin(u_time + p.yx * fi);
        caustics += 0.01 / length(p);
    }
    color += caustics * vec3(0.8, 0.9, 1.0);

    gl_FragColor = vec4(color, 1.0);
}
