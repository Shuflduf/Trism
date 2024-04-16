shader_type canvas_item;

uniform vec4 color_gap: source_color = vec4(0.25);
uniform vec4 color_stripe: source_color = vec4(1.0, 0.75, 0.0, 1.0);
uniform float divisions = 16.0; // increase for more stripe density
uniform float stripe_bias = 2.0; // 1.0 means no stripes; 2.0 means stripes and gaps are equal size
uniform float speed = 0.03;
uniform float angle = 0.7854; // in radians
uniform float mask_width = 0.2; // Width of the mask on the right side, as a fraction of total width
uniform float shadow_width = 0.02;
uniform float zigzag_frequency = 10.0; // Frequency of the zigzag pattern
uniform float zigzag_amplitude = 0.05; // Amplitude of the zigzag pattern

void fragment() {
    // Calculate the zigzag pattern based on the current UV.y coordinate
    float zigzag = sin(UV.y * zigzag_frequency) * zigzag_amplitude + (1.0 - mask_width);
    
    // Calculate the distance to the edge of the mask for the drop shadow effect
    float edgeDistance = smoothstep(0.0, shadow_width, zigzag - UV.x); // Adjust 0.02 to control the width of the shadow
    
    // Check if the current fragment is within the zigzag masked area on the right side
    if (UV.x > zigzag) {
        // Apply a custom effect or color for the masked area
        COLOR = vec4(0.0, 0.0, 0.0, 0.0); // Example: making the masked area transparent
    } else if (UV.x > zigzag - shadow_width) { // Adjust 0.02 to match the smoothstep range for the shadow width
        // Apply the drop shadow effect on the edge of the mask
        vec4 shadowColor = mix(vec4(0.0), vec4(0.0, 0.0, 0.0, 0.3), edgeDistance); // Adjust shadow color and opacity as needed
        COLOR = shadowColor;
    } else {
        // Original shader logic
        float w = cos(angle) * UV.x + sin(angle) * UV.y - speed * TIME;
        if (floor(mod(w * divisions, stripe_bias)) < 0.0001) {
            COLOR = color_gap;
        } else {
            COLOR = color_stripe;
        }
    }
}
