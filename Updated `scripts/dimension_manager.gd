extends Node

@onready var event_bus = get_node("/root/EventBus")
@onready var world_environment = $WorldEnvironment

var post_processing_config: Resource = preload("res://assets/configs/post_processing_config.tres")

func _ready():
    event_bus.connect("dimension_changed", self, "_on_dimension_changed")

func _on_dimension_changed(new_dimension: String):
    apply_post_processing_settings(new_dimension)

func apply_post_processing_settings(dimension: String):
    var config = post_processing_config
    world_environment.environment.adjust_color_grading(config.color_grading)
    world_environment.environment.set_vignette_intensity(config.vignette_intensity)
    world_environment.environment.set_fog_density(config.fog_density)
    world_environment.environment.set_fog_color(config.fog_color)
