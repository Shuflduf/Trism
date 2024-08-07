shader_type canvas_item;

uniform vec2 dir = vec2(1, 1);

void fragment() {
	COLOR = texture(TEXTURE, UV + (vec2(TIME) * dir));
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
