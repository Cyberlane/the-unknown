# scripts/ui/interaction_ui.gd
extends Control

@onready var prompt_label = $PromptLabel

func _ready():
    add_to_group("interaction_ui")
    hide_prompt()

func show_prompt(text: String) -> void:
    prompt_label.text = text
    prompt_label.visible = true

func hide_prompt() -> void:
    prompt_label.visible = false
