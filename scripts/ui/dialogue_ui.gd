# scripts/ui/dialogue_ui.gd
extends Control

@onready var dialogue_panel = $Panel
@onready var dialogue_label = $Panel/MarginContainer/Label

var is_showing: bool = false

func _ready():
    add_to_group("dialogue_ui")
    hide_dialogue()

func show_dialogue(text: String) -> void:
    dialogue_label.text = text
    dialogue_panel.visible = true
    is_showing = true

    # Release mouse to allow clicking through dialogue if needed
    # But player can still press E or Space to close

func hide_dialogue() -> void:
    dialogue_panel.visible = false
    is_showing = false

func _input(event):
    # Close dialogue with E or Space
    if is_showing and (event.is_action_pressed("interact") or event.is_action_pressed("ui_accept")):
        hide_dialogue()
        get_viewport().set_input_as_handled()
