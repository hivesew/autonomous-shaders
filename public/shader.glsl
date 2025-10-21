precision mediump float;

uniform vec2 u_resolution;
uniform float u_time;

// Hash function to generate pseudo-random values
float hash(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

// 2D Simplex noise for a more organic feel
vec3 mod289(vec3 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec2 mod289(vec2 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec3 permute(vec3 x) { return mod289(((x*34.0)+1.0)*x); }

float snoise(vec2 v) {
    const vec4 C = vec4(0.211324865405187,  // (3.0-sqrt(3.0))/6.0
                        0.366025403784439,  // 0.5*(sqrt(3.0)-1.0)
                       -0.577350269189626,  // -1.0 + 2.0 * C.x
                        0.024390243902439); // 1.0 / 41.0
    vec2 i  = floor(v + dot(v, C.yy) );
    vec2 x0 = v -   i + dot(i, C.xx);
    vec2 i1;
    i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
    vec4 x12 = x0.xyxy + C.xxzz;
    x12.xy -= i1;
    i = mod289(i);
    vec3 p = permute( permute( i.y + vec3(0.0, i1.y, 1.0 ))
        + i.x + vec3(0.0, i1.x, 1.0 ));
    vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x12.xy,x12.xy), dot(x12.zw,x12.zw)), 0.0);
    m = m*m ;
    m = m*m ;
    vec3 x = 2.0 * fract(p * C.www) - 1.0;
    vec3 h = abs(x) - 0.5;
    vec3 ox = floor(x + 0.5);
    vec3 a0 = x - ox;
    m *= 1.79284291400159 - 0.85373472095314 * ( a0*a0 + h*h );
    vec3 g;
    g.x  = a0.x  * x0.x  + h.x  * x0.y;
    g.yz = a0.yz * x12.xz + h.yz * x12.yw;
    return 130.0 * dot(m, g);
}

// Fractal Brownian Motion to create dune-like structures
float fbm(vec2 st) {
    float value = 0.0;
    float amplitude = 0.5;
    float frequency = 2.0;
    for (int i = 0; i < 5; i++) {
        value += amplitude * snoise(st * frequency);
        frequency *= 2.0;
        amplitude *= 0.5;
    }
    return value;
}

void main() {
    vec2 st = gl_FragCoord.xy / u_resolution.xy;
    st.x *= u_resolution.x / u_resolution.y;

    // Create base sand dunes that shift slowly
    vec2 dune_coord = st * 2.0;
    float dune_pattern = fbm(dune_coord + vec2(u_time * 0.02, 0.0));

    // Create fine, wind-blown sand ripples on top
    vec2 ripple_coord = st * 15.0;
    float ripple_pattern = snoise(ripple_coord + vec2(u_time * 0.2, u_time * 0.1));
    
    // Combine patterns for a rich sand texture
    float sand = smoothstep(0.1, 0.6, dune_pattern + ripple_pattern * 0.1);

    // --- Ephemeral Memory Visualization ---
    float memory_cycle_duration = 10.0;
    float time_in_cycle = mod(u_time, memory_cycle_duration);
    float cycle_progress = time_in_cycle / memory_cycle_duration;
    
    // Use the cycle number to seed this memory event
    float memory_id = floor(u_time / memory_cycle_duration);
    
    // Generate a random, stable position for the memory event
    vec2 memory_pos = vec2(hash(vec2(memory_id, 0.0)), hash(vec2(memory_id, 1.0)));
    memory_pos = mix(vec2(0.1, 0.1), vec2(0.9, 0.9), memory_pos);
    
    // Create a ghostly, shimmering form for the memory
    float dist_to_memory = distance(st, memory_pos * vec2(1.0, u_resolution.y/u_resolution.x));
    float memory_shape = 1.0 - smoothstep(0.0, 0.3, dist_to_memory);
    memory_shape *= (snoise(st * 30.0 + u_time) * 0.5 + 0.5); // Shimmering texture
    
    // The memory fades in and then dissolves completely
    float memory_intensity = 0.0;
    // Fade in for the first 20% of the cycle
    memory_intensity = smoothstep(0.0, 0.2, cycle_progress); 
    // Fade out for the last 80%
    memory_intensity *= (1.0 - smoothstep(0.2, 1.0, cycle_progress)); 
    
    // Make the fade-out feel like dissolving by using noise
    memory_intensity = smoothstep(0.0, 0.8, memory_intensity - hash(st*50.0 + memory_id) * 0.8);

    // --- Color Palette ---
    vec3 sand_color_light = vec3(0.95, 0.85, 0.7);
    vec3 sand_color_dark = vec3(0.6, 0.45, 0.3);
    vec3 sky_color = vec3(0.1, 0.2, 0.4);
    vec3 memory_color = vec3(0.7, 0.9, 1.0);

    // Base color from sand pattern
    vec3 color = mix(sand_color_dark, sand_color_light, sand);
    
    // Add a hint of sky reflection in the darker parts of the dunes
    color = mix(sky_color, color, smoothstep(0.45, 0.55, sand));

    // Blend the ephemeral memory over the top
    color = mix(color, memory_color, memory_shape * memory_intensity * 0.7);
    
    // Final touch: Add a subtle vignette
    float vignette = 1.0 - smoothstep(0.7, 1.5, length(st - 0.5));
    
    gl_FragColor = vec4(color * vignette, 1.0);
}
