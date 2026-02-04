# scripts/interactable.gd
class_name Interactable
extends Node3D

@export_group("Interaction")
@export var interaction_prompt: String = "Press E to interact"
@export_multiline var dialogue_text: String = "This is an interactable object."
@export var interaction_enabled: bool = true

signal interacted(interactor: Node)

func get_interaction_prompt() -> String:
    return interaction_prompt

func interact(interactor: Node) -> void:
    if not interaction_enabled:
        return

    print("Interacted with: ", name)
    interacted.emit(interactor)

    # Trigger dialogue if text is set
    if dialogue_text and not dialogue_text.is_empty():
        _show_dialogue()

func _show_dialogue() -> void:
    # Find the DialogueUI in the scene
    var dialogue_ui = get_tree().get_first_node_in_group("dialogue_ui")
    if dialogue_ui and dialogue_ui.has_method("show_dialogue"):
        dialogue_ui.show_dialogue(dialogue_text)
