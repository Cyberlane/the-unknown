extends EditorCommand
class_name DeleteBlockCommand
## Command for deleting a block

var block_placer: BlockPlacer
var block_data: Dictionary
var deleted_block: PlaceableBlock = null


func _init(placer: BlockPlacer, block: PlaceableBlock) -> void:
	super._init()
	block_placer = placer
	deleted_block = block

	# Store block data for restoration
	if block:
		block_data = block.get_save_data()
		description = "Delete %s at (%d, %d, %d)" % [
			block.block_type.capitalize(),
			int(block.grid_position.x),
			int(block.grid_position.y),
			int(block.grid_position.z)
		]


func execute() -> void:
	if !deleted_block or !block_placer:
		return

	# Remove from tracking
	var key := block_placer.get_grid_key(deleted_block.grid_position)
	block_placer.placed_blocks.erase(key)
	block_placer.blocks_by_id.erase(deleted_block.block_id)

	# Remove from scene
	deleted_block.queue_free()
	deleted_block = null


func undo() -> void:
	if !block_placer or !block_placer.block_palette:
		return

	# Recreate block from saved data
	var block_type: String = block_data.get("block_type", "")
	var rotation: int = block_data.get("rotation", 0)
	var pos_data: Dictionary = block_data.get("position", {})
	var grid_pos := Vector3(
		pos_data.get("x", 0),
		pos_data.get("y", 0),
		pos_data.get("z", 0)
	)

	# Create block
	deleted_block = block_placer.block_palette.create_block_instance(
		block_type,
		grid_pos,
		rotation
	)

	if !deleted_block:
		push_error("[DeleteBlockCommand] Failed to recreate block")
		return

	# Load full data
	deleted_block.load_from_data(block_data)

	# Add to scene
	block_placer.level_root.add_child(deleted_block)

	# Track the block
	var key := block_placer.get_grid_key(grid_pos)
	block_placer.placed_blocks[key] = deleted_block
	block_placer.blocks_by_id[deleted_block.block_id] = deleted_block
