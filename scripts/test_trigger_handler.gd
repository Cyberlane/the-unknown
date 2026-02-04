# scripts/test_trigger_handler.gd
# Example script showing how to use DimensionTrigger
extends Node

@export var trigger: DimensionTrigger
@export_multiline var message: String = "You've activated a dimension-specific trigger!"

func _ready():
    if trigger:
        trigger.dimension_triggered.connect(_on_trigger_activated)

func _on_trigger_activated(body: Node3D):
    print("Trigger activated by: ", body.name)

    # Show message in dialogue UI
    var dialogue_ui = get_tree().get_first_node_in_group("dialogue_ui")
    if dialogue_ui and dialogue_ui.has_method("show_dialogue"):
        dialogue_ui.show_dialogue(message)
