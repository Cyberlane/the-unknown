extends Node

## VoiceTrigger - Simple helper that shows a message when a DimensionTrigger fires
##
## Attach this to a DimensionTrigger to automatically show dialogue when triggered

@export var dimension_trigger: DimensionTrigger
@export_multiline var voice_message: String = "You hear a mysterious voice..."
@export var auto_dismiss_time: float = 4.0

func _ready():
    if dimension_trigger:
        dimension_trigger.dimension_triggered.connect(_on_trigger_activated)
    else:
        push_warning("VoiceTrigger: No DimensionTrigger assigned!")

func _on_trigger_activated(body: Node3D):
    # Show the voice message
    _show_message(voice_message)

func _show_message(text: String):
    print("Voice Trigger: ", text)

    # Try to use DialogueUI if available
    var dialogue_ui = get_node_or_null("/root/DialogueUI")
    if dialogue_ui and dialogue_ui.has_method("show_dialogue"):
        dialogue_ui.show_dialogue(text)

        # Auto-dismiss after time
        if auto_dismiss_time > 0:
            await get_tree().create_timer(auto_dismiss_time).timeout
            if dialogue_ui.has_method("hide_dialogue"):
                dialogue_ui.hide_dialogue()
