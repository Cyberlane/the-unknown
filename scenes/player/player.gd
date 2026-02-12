# scenes/player/player.gd
extends CharacterBody3D

var health: int 100
var sanity: int 100

func _ready():
    get_tree().call_group("event_bus", "player_stats_changed", self, "health", health)
    get_tree().call_group("event_bus", "player_stats_changed", self, "sanity", sanity)
