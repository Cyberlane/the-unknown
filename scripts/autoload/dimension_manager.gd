extends Node

@export var preview_dimensions: Array = []

func _ready():
    EventBus.connect("dimension_toggle", self, "_on_dimension_toggle")

func _on_dimension_toggle(dimension_index):
    if dimension_index > 0 and dimension_index <= preview_dimensions.size():
        var active_dim = preview_dimensions[dimension_index - 1]
        # Assuming there's a way to switch dimensions, e.g., by calling a method on the player
        get_node("/root/Main/Player").switch_dimension(active_dim)
