# scripts/dimension_ambient_audio.gd
extends Node

@export_group("Ambient Audio Loops")
@export var normal_ambient: AudioStream
@export var viking_ambient: AudioStream
@export var aztec_ambient: AudioStream
@export var nightmare_ambient: AudioStream

@export_group("Crossfade Settings")
@export var crossfade_duration: float = 2.0
@export var silent_volume_db: float = -80.0
@export var active_volume_db: float = 0.0

# Audio players (one per dimension)
var audio_players: Dictionary = {}
var current_dimension: int = -1
var crossfade_tween: Tween

func _ready():
    # Create audio players for each dimension
    _setup_audio_players()

    # Connect to dimension changes
    DimensionManager.dimension_changed.connect(_on_dimension_changed)

    # Set initial dimension
    current_dimension = DimensionManager.current_dimension
    _crossfade_to_dimension(current_dimension, 0.0)  # Instant on startup

func _setup_audio_players():
    # Create players for each dimension
    var dimensions = [
        {"id": DimensionManager.Dimension.NORMAL, "stream": normal_ambient, "name": "NormalAmbient"},
        {"id": DimensionManager.Dimension.VIKING, "stream": viking_ambient, "name": "VikingAmbient"},
        {"id": DimensionManager.Dimension.AZTEC, "stream": aztec_ambient, "name": "AztecAmbient"},
        {"id": DimensionManager.Dimension.NIGHTMARE, "stream": nightmare_ambient, "name": "NightmareAmbient"}
    ]

    for dim_data in dimensions:
        var player = AudioStreamPlayer.new()
        player.name = dim_data.name
        player.stream = dim_data.stream
        player.volume_db = silent_volume_db
        player.bus = "Ambient"  # Route to Ambient bus
        player.autoplay = false  # We'll start manually

        add_child(player)
        audio_players[dim_data.id] = player

        # Start playing if stream is assigned
        if player.stream:
            player.play()
            print("Started ambient loop: ", player.name)

func _on_dimension_changed(new_dim):
    if new_dim == current_dimension:
        return

    _crossfade_to_dimension(new_dim, crossfade_duration)
    current_dimension = new_dim

func _crossfade_to_dimension(target_dim: int, duration: float):
    # Kill any existing crossfade
    if crossfade_tween:
        crossfade_tween.kill()

    # Create new tween
    crossfade_tween = create_tween()
    crossfade_tween.set_parallel(true)  # Fade all simultaneously
    crossfade_tween.set_ease(Tween.EASE_IN_OUT)
    crossfade_tween.set_trans(Tween.TRANS_CUBIC)

    # Fade each dimension's audio
    for dim_id in audio_players.keys():
        var player = audio_players[dim_id]

        if not player or not player.stream:
            continue

        # Determine target volume
        var target_volume = silent_volume_db
        if dim_id == target_dim:
            target_volume = active_volume_db

        # Tween to target volume
        if duration > 0:
            crossfade_tween.tween_property(player, "volume_db", target_volume, duration)
        else:
            # Instant change
            player.volume_db = target_volume

    if duration > 0:
        print("Crossfading to dimension ", DimensionManager.Dimension.keys()[target_dim], " over ", duration, "s")

# Optional: Manual control functions
func set_ambient_volume(dimension: int, volume_db: float):
    if audio_players.has(dimension):
        audio_players[dimension].volume_db = volume_db

func get_ambient_volume(dimension: int) -> float:
    if audio_players.has(dimension):
        return audio_players[dimension].volume_db
    return silent_volume_db

func stop_all_ambient():
    for player in audio_players.values():
        if player:
            player.stop()

func resume_all_ambient():
    for player in audio_players.values():
        if player and player.stream:
            player.play()
