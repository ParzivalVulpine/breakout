@tool
extends Node2D

@export_group("Grid Settings")
@export var scene_to_instantiate: PackedScene
@export var grid_width: int = 5
@export var grid_height: int = 5
@export var cell_spacing: Vector2 = Vector2(100, 100)
@export var grid_offset: Vector2 = Vector2.ZERO

var generated_instances: Array[Node] = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	generate_scene_grid()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

# Get instance at specific grid coordinates
func get_instance_at_grid(grid_pos: Vector2i) -> Node:
	if grid_pos.x < 0 or grid_pos.x >= grid_width or grid_pos.y < 0 or grid_pos.y >= grid_height:
		return null

	var index = grid_pos.y * grid_width + grid_pos.x
	if index < generated_instances.size():
		return generated_instances[index]

	return null

# Get all instances in the grid
func get_all_instances() -> Array[Node]:
	return generated_instances.duplicate()

func generate_scene_grid():
	if not scene_to_instantiate:
		push_warning("GridGenerator: No scene assigned to instantiate!")
		return

	print("Generating grid: %dx%d with spacing %s" % [grid_width, grid_height, cell_spacing])

	for y in range(grid_height):
		for x in range(grid_width):
			var instance = scene_to_instantiate.instantiate()

			# Calculate position
			var pos = Vector2(x * cell_spacing.x, y * cell_spacing.y) + grid_offset

			# Set position based on node type
			if instance is Node2D:
				instance.position = pos
			elif instance is Control:
				instance.position = pos
			elif instance is Node3D:
				# For 3D nodes, convert to 3D position
				instance.position = Vector3(pos.x, 0, pos.y)

			# Add to scene tree
			add_child(instance)

			# Set owner for proper saving in editor
			if Engine.is_editor_hint():
				instance.owner = get_tree().edited_scene_root

			# Store reference for later cleanup
			generated_instances.append(instance)

			# Optional: Set a name for easier identification
			instance.name = "GridItem_%d_%d" % [x, y]

	print("Grid generation complete! Generated %d instances." % generated_instances.size())
