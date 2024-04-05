shader_type canvas_item;

// Uniforms
uniform sampler2D deadTexture; // Texture for dead cells
uniform sampler2D aliveTexture; // Texture for alive cells
uniform sampler2D binaryDataTexture; // Texture containing binary data
uniform int gridWidth; // Width of the grid
uniform int cellSize; // Size of each cell

void fragment() {
	// Calculate the size of the grid
	vec2 gridSize = vec2(float(gridWidth) * float(cellSize));
	
	// Scale the UV coordinates by the grid width
	vec2 scaledUV = UV * float(gridWidth);
	
	// Calculate the index of the cell in the grid
	ivec2 cellIndex = ivec2(floor(scaledUV));
	
	// Calculate the UV coordinates within the cell
	vec2 cellUV = fract(scaledUV);
	
	// Check if the UV coordinates are inside the cell
	bool isInsideCell = all(greaterThanEqual(cellUV, vec2(0.0))) && all(lessThan(cellUV, vec2(1.0)));
	
	// Calculate the UV coordinates within the binary data texture
	vec2 binaryDataUV = vec2(
		float(cellIndex.x) / float(gridWidth - 1),
		float(cellIndex.y) / float(gridWidth - 1)
	);
	
	// Get the binary value from the binary data texture
	float binaryValue = texture(binaryDataTexture, binaryDataUV).r;
	
	// Check if the cell is white (binary value > 0.5)
	bool isWhite = binaryValue > 0.5;
	
	// Calculate the distance to the nearest border of the cell
	float distanceX = min(scaledUV.x, float(gridWidth) - scaledUV.x) * float(cellSize);
	float distanceY = min(scaledUV.y, float(gridWidth) - scaledUV.y) * float(cellSize);
	float distanceToBorder = min(distanceX, distanceY);
	
	// Get the color from the dead texture
	vec4 color = texture(deadTexture, cellUV);
	
	// If the cell is white and inside the cell, get the color from the alive texture
	if (isWhite && isInsideCell) {
		color = texture(aliveTexture, cellUV);
	}
	
	// Set the output color
	COLOR = color;
}
