shader_type canvas_item;

// Uniforms
uniform sampler2D dead_texture; // Texture for dead cells
uniform sampler2D alive_texture; // Texture for alive cells
uniform sampler2D binary_data_texture; // Texture containing binary data
uniform int grid_width; // Width of the grid
uniform int cell_size; // Size of each cell

void fragment() {
	// Calculate the size of the grid
	vec2 grid_size = vec2(float(grid_width) * float(cell_size));
	
	// Scale the UV coordinates by the grid width
	vec2 scaled_uv = UV * float(grid_width);
	
	// Calculate the index of the cell in the grid
	ivec2 cell_index = ivec2(floor(scaled_uv));
	
	// Calculate the UV coordinates within the cell
	vec2 cell_uv = fract(scaled_uv);
	
	// Check if the UV coordinates are inside the cell
	bool is_inside_cell = all(greaterThanEqual(cell_uv, vec2(0.0))) && all(lessThan(cell_uv, vec2(1.0)));
	
	// Calculate the UV coordinates within the binary data texture
	vec2 binary_data_uv = vec2(
		float(cell_index.x) / float(grid_width - 1),
		float(cell_index.y) / float(grid_width - 1)
	);
	
	// Get the binary value from the binary data texture
	float binary_value = texture(binary_data_texture, binary_data_uv).r;
	
	// Check if the cell is white (binary value > 0.5)
	bool is_white = binary_value > 0.5;
	
	// Calculate the distance to the nearest border of the cell
	float distance_x = min(scaled_uv.x, float(grid_width) - scaled_uv.x) * float(cell_size);
	float distance_y = min(scaled_uv.y, float(grid_width) - scaled_uv.y) * float(cell_size);
	float distance_to_border = min(distance_x, distance_y);
	
	// Get the color from the dead texture
	vec4 color = texture(dead_texture, cell_uv);
	
	// If the cell is white and inside the cell, get the color from the alive texture
	if (is_white && is_inside_cell) {
		color = texture(alive_texture, cell_uv);
	}
	
	// Set the output color
	COLOR = color;
}
