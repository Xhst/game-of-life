extends Node

"""
Controls a cellular automaton simulation using a compute shader.

This script manages the setup, execution, and rendering of a cellular automaton simulation
using a compute shader. It includes functionality for initializing simulation parameters,
loading compute shaders, setting up rendering materials, and executing the simulation loop.

"""

# Exported variables
@export_range(1, 1000)
var update_every_ms: int = 200
"""int: Time interval between updates of the simulation, in milliseconds."""

@export_file
var compute_shader: String
"""str: Path to the compute shader file."""

@export_range(32, 2048)
var square_size: int
"""int: Size of the square grid for the simulation."""

@export
var alive_texture: Texture2D
"""Texture2D: Texture representing live cells."""

@export
var dead_texture: Texture2D
"""Texture2D: Texture representing dead cells."""

@export
var binary_data_texture: Texture2D
"""Texture2D: Optional binary data texture for initial state."""

@export_range(0.0, 1.0)
var noise_frequency: float
"""float: Frequency of noise for generating random initial state."""

# References to nodes in the scene
@onready var viewport: Viewport = %Viewport2D
@onready var viewport_sprite: Sprite2D = %ViewportSprite
@onready var torus: MeshInstance3D = %Torus

# Arrays and variables for rendering
var bindings: Array[RDUniform] = []
var rendering_device: RenderingDevice
var render_texture: ImageTexture
var input_image: Image
var output_image: Image
var input_format: RDTextureFormat
var output_format: RDTextureFormat
var input_texture: RID
var output_texture: RID
var shader: RID
var uniform_set: RID
var pipeline: RID


func _ready():
	"""Called when the node is added to the scene.

	Initializes the simulation by setting up parameters, loading resources,
	and preparing rendering components.
	"""
	input_image = _get_input_image()
	output_image = Image.create(square_size, square_size, false, Image.FORMAT_L8)
	_merge_input_and_output_images()
	_set_shader_material_from_output_image()
	_set_tourus_viewport_material()
	rendering_device = RenderingServer.create_local_rendering_device()
	shader = _create_shader()
	pipeline = rendering_device.compute_pipeline_create(shader)
	input_format = _get_base_texture_format()
	output_format = _get_base_texture_format()
	_compute_bindings()
	_game_process()


func _get_input_image() -> Image:
	"""Retrieve the input image for the simulation.

	If a binary data texture is provided, it is used as the input image.
	Otherwise, a noise image is generated based on the specified frequency.
	Returns:
		Image: The input image for the simulation.
	"""
	if binary_data_texture == null:
		return _get_noise_image()
	
	square_size = int(binary_data_texture.get_size().x)
	
	return binary_data_texture.get_image()


func _get_noise_image() -> Image:
	"""Generate a noise image for initial state.

	Uses a noise generator to create a random noise image based on the
	specified frequency.
	Returns:
		Image: The noise image for initial state.
	"""
	var rng = RandomNumberGenerator.new()
	
	var noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise.frequency = noise_frequency
	noise.seed = rng.randi()
	
	return noise.get_image(square_size, square_size)


func _merge_input_and_output_images() -> void:
	"""Merge input and output images for initial setup."""
	for x in range(0, square_size):
		for y in range(0, square_size):
			var color := input_image.get_pixel(x, y)
			output_image.set_pixel(x, y, color)
	
	input_image.set_data(
		square_size, 
		square_size, 
		false, 
		Image.FORMAT_L8, 
		output_image.get_data()
	)


func _set_shader_material_from_output_image() -> void:
	"""Set shader parameters for materials."""
	var material = viewport_sprite.material as ShaderMaterial
	
	render_texture = ImageTexture.create_from_image(output_image)
	
	if material == null: 
		return
		
	var cell_size = int(alive_texture.get_size().x);
	
	material.set_shader_parameter("deadTexture", dead_texture)
	material.set_shader_parameter("aliveTexture", alive_texture)
	material.set_shader_parameter("binaryDataTexture", render_texture)
	material.set_shader_parameter("gridWidth", square_size)
	material.set_shader_parameter("cellSize", cell_size)


func _set_tourus_viewport_material() -> void:
	"""Set material for torus viewport."""
	var material = StandardMaterial3D.new()
	material.albedo_texture = viewport.get_texture()
	
	torus.set_surface_override_material(0, material)


func _create_shader() -> RID:
	"""Load and create the compute shader."""
	var shader_file: RDShaderFile = load(compute_shader)
	
	var spirv = shader_file.get_spirv()
	
	return rendering_device.shader_create_from_spirv(spirv)


func _get_base_texture_format() -> RDTextureFormat:
	"""Define base texture format for input/output textures."""
	var base_texture_format = RDTextureFormat.new()
	
	base_texture_format.width = square_size
	base_texture_format.height = square_size
	base_texture_format.format = RenderingDevice.DATA_FORMAT_R8_UNORM
	
	base_texture_format.usage_bits = (
		RenderingDevice.TEXTURE_USAGE_STORAGE_BIT | 
		RenderingDevice.TEXTURE_USAGE_CAN_UPDATE_BIT | 
		RenderingDevice.TEXTURE_USAGE_CAN_COPY_FROM_BIT
	)
	
	return base_texture_format


func _compute_bindings() -> void:
	"""Create bindings for the compute shader."""
	var input := PackedInt32Array([square_size, square_size])
	var input_bytes := input.to_byte_array()
	var buffer := rendering_device.storage_buffer_create(input_bytes.size(), input_bytes)
	var uniform := RDUniform.new()
	uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	uniform.binding = 0
	uniform.add_id(buffer)
	bindings.append(uniform)
	
	input_texture = _create_texture_and_bind_uniform(input_image, input_format, 1)
	output_texture = _create_texture_and_bind_uniform(output_image, output_format, 2)
	
	uniform_set = rendering_device.uniform_set_create(bindings, shader, 0)


func _create_texture_and_bind_uniform(image: Image, format: RDTextureFormat, binding: int) -> RID:
	"""Create texture and bind uniform for the compute shader."""
	var view = RDTextureView.new()
	
	var data = [image.get_data()]
	
	var texture = rendering_device.texture_create(format, view, data)
	
	var uniform = RDUniform.new()
	uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	uniform.binding = binding
	uniform.add_id(texture)
	
	bindings.append(uniform)
	
	return texture


func _game_process() -> void:
	"""Main game loop controlling the update and rendering."""
	while (true):
		_update()
		await sleep(update_every_ms)
		_render()


func sleep(ms: int):
	"""Sleep function to control update frequency."""
	await get_tree().create_timer(float(ms) / 1000.0).timeout 


func _update() -> void:
	"""Update function for the compute shader."""
	var compute_list = rendering_device.compute_list_begin()
	
	var groups = 32
	
	rendering_device.compute_list_bind_compute_pipeline(compute_list, pipeline)
	rendering_device.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
	rendering_device.compute_list_dispatch(compute_list, groups, groups, 1)
	rendering_device.compute_list_end()
	rendering_device.submit()


func _render() -> void:
	"""Render function to update textures and perform rendering."""
	rendering_device.sync()
	
	var bytes = rendering_device.texture_get_data(output_texture, 0)
	
	rendering_device.texture_update(input_texture, 0, bytes)
	
	output_image.set_data(square_size, square_size, false, Image.FORMAT_L8, bytes)
	
	render_texture.update(output_image)
