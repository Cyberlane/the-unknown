extends EditorCommand
class_name PlaceBlockCommand
## Command for placing a block

var block_placer: BlockPlacer
var block_type: String
var grid_position: Vector3
var rotation_index: int
var dimension_tags: Array[String]
var placed_block: PlaceableBlock = null


func _init(placer: BlockPlacer, type: String, pos: Vector3, rot: int = 0, tags: Array[String] = []) -> void:
	super._init()
	block_placer = placer
	block_type = type
	grid_position = pos
	rotation_index = rot
	dimension_tags = tags if tags.size() > 0 else ["Normal", "Aztec", "Viking", "Nightmare"]
	description = "Place %s at (%d, %d, %d)" % [type.capitalize(), int(pos.x), int(pos.y), int(pos.z)]


func execute() -> void:
	if !block_placer or !block_placer.block_palette:
		return

	# Create block
	placed_block = block_placer.block_palette.create_block_instance(
		block_type,
		grid_position,
		rotation_index
	)

	if !placed_block:
		push_error("[PlaceBlockCommand] Failed to create block")
		return

	# Set dimension tags
	placed_block.set_dimension_tags(dimension_tags)

	# Add to scene
	block_placer.level_root.add_child(placed_block)

	# Track the block
	var key := block_placer.get_grid_key(grid_position)
	block_placer.placed_blocks[key] = placed_block
	block_placer.blocks_by_id[placed_block.block_id] = placed_block


func undo() -> void:
	if !placed_block or !block_placer:
		return

	# Remove from tracking
	var key := block_placer.get_grid_key(grid_position)
	block_placer.placed_blocks.erase(key)
	block_placer.blocks_by_id.erase(placed_block.block_id)

	# Remove from scene
	placed_block.queue_free()
	placed_block = null
