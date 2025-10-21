precision mediump float;

uniform vec2 u_resolution;
uniform float u_time;

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

// Fractal Brownian Motion to create noise with multiple levels of detail
float fbm(vec2 st) {
    float value = 0.0;
    float amplitude = 0.5;
    float frequency = 2.0;
    for (int i = 0; i < 6; i++) {
        value += amplitude * snoise(st * frequency);
        frequency *= 2.1;
        amplitude *= 0.45;
    }
    return value;
}

// Hash function to generate pseudo-random values
float hash(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

void main() {
    // Center and aspect-correct the coordinate system
    vec2 st = (gl_FragCoord.xy * 2.0 - u_resolution.xy) / min(u_resolution.x, u_resolution.y);

    vec3 color = vec3(0.0);

    // --- Nebula ---
    vec2 nebula_coord = st;
    float angle = atan(nebula_coord.y, nebula_coord.x);
    float dist_from_center = length(nebula_coord);
    
    // Add a swirling motion to the nebula, stronger towards the center
    nebula_coord += u_time * 0.05; // General drift
    float swirl_strength = 0.2 / (dist_from_center + 0.5);
    nebula_coord.x += sin(angle * 2.0 + u_time * 0.1) * swirl_strength;
    nebula_coord.y += cos(angle * 2.0 + u_time * 0.1) * swirl_strength;

    // Generate the base nebula cloud structure
    float nebula_density = fbm(nebula_coord * 2.5);
    
    // Color the nebula with a mix of deep space colors
    vec3 nebula_color1 = vec3(0.1, 0.2, 0.5); // Deep Blue
    vec3 nebula_color2 = vec3(0.6, 0.3, 0.8); // Purple/Pink
    vec3 nebula_color = mix(nebula_color1, nebula_color2, smoothstep(0.3, 0.7, nebula_density));
    
    color = mix(color, nebula_color, smoothstep(0.4, 0.6, nebula_density));

    // --- Distant Stars / Cosmic Dust ---
    float stars = 0.0;
    vec2 star_grid = floor(st * 100.0);
    float star_hash = hash(star_grid);
    
    // Create a sparse, twinkling starfield
    if (star_hash > 0.995) {
        vec2 star_pos = fract(st * 100.0) - 0.5;
        float star_brightness = 1.0 - length(star_pos);
        star_brightness = smoothstep(0.0, 1.0, star_brightness);
        // Twinkle effect
        stars = star_brightness * (sin(u_time * 2.0 + star_hash * 100.0) * 0.5 + 0.5);
    }
    color += vec3(stars);

    // --- Protostar Formation ---
    // The star grows over the first 20 seconds
    float star_size = mix(0.01, 0.2, smoothstep(0.0, 20.0, u_time)); 
    float core_dist = distance(st, vec2(0.0));
    
    // A bright, glowing core
    float core_glow = 1.0 / (core_dist * 200.0 + 1.0);
    core_glow = pow(core_glow, 2.0);
    
    // A pulsating central body
    float pulse = sin(u_time * 3.0) * 0.5 + 0.5;
    float core_shape = smoothstep(star_size, star_size - 0.05, core_dist);
    core_shape *= pulse * 0.5 + 0.5;
    
    vec3 star_color = vec3(1.0, 0.95, 0.8);
    color += core_glow * star_color * 2.0; // Additive glow
    color = mix(color, star_color, core_shape); // Mix in the core shape

    // --- God Rays ---
    float rays = 0.0;
    vec2 ray_coord = st;
    float ray_angle = atan(ray_coord.y, ray_coord.x);
    // Use noise to create uneven, shimmering rays
    float ray_noise = snoise(vec2(ray_angle * 5.0, u_time * 0.5));
    rays = smoothstep(0.5, 0.6, ray_noise) * 0.3;
    rays /= (core_dist * 2.0 + 1.0); // Rays fade with distance
    rays *= smoothstep(0.0, 0.5, core_dist); // Rays are stronger away from the core
    
    color += rays * star_color * (pulse * 0.5 + 0.5);

    // --- Final Composition ---
    color = pow(color, vec3(0.8)); // Simple tone mapping
    color = clamp(color, 0.0, 1.0);

    gl_FragColor = vec4(color, 1.0);
}