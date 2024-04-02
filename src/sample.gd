class_name Sample
enum Name {
	NONE,
	GLIDER,
	GOSPER_GLIDER_CANNON,
	PULSAR
}

static func texture_from_name(name: Sample.Name) -> Texture2D:
	if name == Sample.Name.NONE:
		return null
		
	var sample_dir = "res://images/samples/"
	var sample_name = str(Name.keys()[name]).to_lower()
	var path = sample_dir + sample_name + '.png'

	var texture: Texture2D = load(path)
	
	return texture
