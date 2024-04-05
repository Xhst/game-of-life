class_name Sample
"""
The Sample class provides functionality for working with sample textures.
"""

enum Name {
	NONE,
	GLIDER,
	GOSPER_GLIDER_CANNON,
	PULSAR,
	DIEHARD,
	BLOCKLAYING_SWITCH_ENGINE_1,
	BLOCKLAYING_SWITCH_ENGINE_2,
}

static func texture_from_name(name: Sample.Name) -> Texture2D:
	"""
	Returns the texture corresponding to the given sample name.

	Args:
		name (Sample.Name): The name of the sample.

	Returns:
		Texture2D: The texture corresponding to the given sample name.
	"""
	# Check if the name is NONE
	if name == Sample.Name.NONE:
		return null

	# Define the directory and file name for the sample texture
	var sample_dir = 'res://images/samples/'
	var sample_name = str(Name.keys()[name]).to_lower()
	var path = sample_dir + sample_name + '.png'

	# Load the texture from the specified path
	var texture: Texture2D = load(path)

	return texture
