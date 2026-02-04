# scripts/viking_choice_example.gd
# Example: Interactable that gives Viking trust based on player action
extends Interactable

@export var trust_amount: int = 10
@export var choice_id: String = "viking_advice_followed"
@export_multiline var trust_message: String = "The Viking spirits approve of your actions.\n\n+10 Viking Trust"

var has_given_trust: bool = false

func interact(interactor: Node) -> void:
    # Don't give trust multiple times
    if has_given_trust:
        super.interact(interactor)
        return

    # Record the choice
    ChoiceManager.record_choice(choice_id, {
        "dimension": DimensionManager.current_dimension,
        "trust_given": trust_amount
    })

    # Give Viking trust
    ChoiceManager.modify_viking_trust(trust_amount, "Followed Viking advice")

    # Show trust message
    var dialogue_ui = get_tree().get_first_node_in_group("dialogue_ui")
    if dialogue_ui and dialogue_ui.has_method("show_dialogue"):
        dialogue_ui.show_dialogue(trust_message)

    has_given_trust = true

    # Call base implementation
    interacted.emit(interactor)
