shader_type canvas_item;

uniform sampler2D deadTexture;
uniform sampler2D aliveTexture;
uniform sampler2D binaryDataTexture;
uniform int gridWidth;  
uniform int cellSize;

void fragment() {
	vec2 gridSize = vec2(float(gridWidth) * float(cellSize));
	
	vec2 scaledUV = UV * float(gridWidth);
	
	ivec2 cellIndex = ivec2(floor(scaledUV));
	
	vec2 cellUV = fract(scaledUV);
	bool isInsideCell = all(greaterThanEqual(cellUV, vec2(0.0))) && all(lessThan(cellUV, vec2(1.0)));
	
	vec2 binaryDataUV = vec2(
		float(cellIndex.x) / float(gridWidth - 1),
		float(cellIndex.y) / float(gridWidth - 1)
	);
	
	float binaryValue = texture(binaryDataTexture, binaryDataUV).r;
	
	bool isWhite = binaryValue > 0.5;
	
	float distanceX = min(scaledUV.x, float(gridWidth) - scaledUV.x) * float(cellSize);
	float distanceY = min(scaledUV.y, float(gridWidth) - scaledUV.y) * float(cellSize);
	
	float distanceToBorder = min(distanceX, distanceY);
	
	vec4 color = texture(deadTexture, cellUV);
	
	if (isWhite && isInsideCell) {
		color = texture(aliveTexture, cellUV);
	}
	
	COLOR = color;
}
