# scripts/level_region.gd
class_name LevelRegion
extends Node3D

@export_group("Dimension Sub-Scenes")
@export var normal_scene: PackedScene
@export var viking_scene: PackedScene
@export var aztec_scene: PackedScene
@export var nightmare_scene: PackedScene

@export_group("Proximity Loading Settings")
@export var load_distance: float = 50.0  ## Distance at which to load sub-scenes
@export var unload_distance: float = 75.0  ## Distance at which to unload sub-scenes (should be > load_distance)
@export var check_interval: float = 0.5  ## How often to check distance (seconds)

@export_group("Debug")
@export var debug_mode: bool = false  ## Print debug messages
@export var show_debug_sphere: bool = false  ## Show visual debug sphere in editor

# Signals
signal region_loaded(dimension: int)
signal region_unloaded()

# Internal state
var current_dimension: int = -1
var is_loaded: bool = false
var active_scene_instance: Node = null
var player: Node3D = null
var distance_check_timer: float = 0.0

# Cached scenes dictionary
var dimension_scenes: Dictionary = {}

func _ready():
    # Build dimension scenes lookup
    dimension_scenes = {
        DimensionManager.Dimension.NORMAL: normal_scene,
        DimensionManager.Dimension.VIKING: viking_scene,
        DimensionManager.Dimension.AZTEC: aztec_scene,
        DimensionManager.Dimension.NIGHTMARE: nightmare_scene
    }

    # Find player in scene
    _find_player()

    # Connect to dimension manager
    DimensionManager.dimension_changed.connect(_on_dimension_changed)

    # Set initial dimension
    current_dimension = DimensionManager.current_dimension

    # Initial proximity check
    _check_proximity()

    if debug_mode:
        print("LevelRegion initialized at ", global_position)

func _process(delta):
    if not player:
        _find_player()
        return

    # Periodic distance checking
    distance_check_timer += delta
    if distance_check_timer >= check_interval:
        distance_check_timer = 0.0
        _check_proximity()

func _check_proximity():
    if not player:
        return

    var distance = global_position.distance_to(player.global_position)

    if debug_mode:
        print("LevelRegion distance to player: ", distance)

    # Load if close and not loaded
    if distance <= load_distance and not is_loaded:
        _load_region()

    # Unload if far and loaded
    elif distance >= unload_distance and is_loaded:
        _unload_region()

func _load_region():
    if is_loaded:
        return

    if debug_mode:
        print("Loading LevelRegion at ", global_position)

    # Load the scene for current dimension
    _swap_to_dimension(current_dimension)

    is_loaded = true
    region_loaded.emit(current_dimension)

func _unload_region():
    if not is_loaded:
        return

    if debug_mode:
        print("Unloading LevelRegion at ", global_position)

    # Remove active scene instance
    if active_scene_instance:
        active_scene_instance.queue_free()
        active_scene_instance = null

    is_loaded = false
    region_unloaded.emit()

func _on_dimension_changed(new_dim):
    if new_dim == current_dimension:
        return

    current_dimension = new_dim

    # Only swap if region is loaded
    if is_loaded:
        _swap_to_dimension(new_dim)

func _swap_to_dimension(target_dim: int):
    # Remove old scene instance
    if active_scene_instance:
        active_scene_instance.queue_free()
        active_scene_instance = null

    # Get scene for target dimension
    var scene_to_load = dimension_scenes.get(target_dim)

    if not scene_to_load:
        if debug_mode:
            print("LevelRegion: No scene assigned for dimension ", DimensionManager.Dimension.keys()[target_dim])
        return

    # Instance and add new scene
    active_scene_instance = scene_to_load.instantiate()
    add_child(active_scene_instance)

    if debug_mode:
        print("LevelRegion: Swapped to dimension ", DimensionManager.Dimension.keys()[target_dim])

func _find_player():
    # Try to find player by group
    var players = get_tree().get_nodes_in_group("player")
    if players.size() > 0:
        player = players[0]
        if debug_mode:
            print("LevelRegion: Found player")
        return

    # Fallback: search for node named "Player"
    player = get_tree().root.find_child("Player", true, false)
    if player and debug_mode:
        print("LevelRegion: Found player by name")

# Public API

## Force load this region regardless of distance
func force_load():
    _load_region()

## Force unload this region regardless of distance
func force_unload():
    _unload_region()

## Get current load state
func is_region_loaded() -> bool:
    return is_loaded

## Get distance to player
func get_distance_to_player() -> float:
    if player:
        return global_position.distance_to(player.global_position)
    return INF

## Manually set player reference (useful if player spawns after regions)
func set_player_reference(player_node: Node3D):
    player = player_node
    if debug_mode:
        print("LevelRegion: Player reference set manually")

func _exit_tree():
    # Clean up when region is removed
    if active_scene_instance:
        active_scene_instance.queue_free()
        active_scene_instance = null
