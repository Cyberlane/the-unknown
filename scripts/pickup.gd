extends "res://scripts/interactable.gd"

## Pickup - Example interactable that can be collected once
##
## Uses PersistenceManager to track collected state across dimensions
## and scene reloads. Once collected, the pickup will remain hidden.

# Unique identifier for this pickup (MUST be unique across entire game)
# Format suggestion: "area_name_item_name" (e.g., "forest_health_potion_01")
@export var pickup_id: String = ""

# What to display when player looks at uncollected pickup
@export var interaction_prompt: String = "Press E to collect"

# What to say when collected
@export var collected_message: String = "Item collected!"

# Optional: Auto-hide the pickup if already collected
@export var auto_hide_if_collected: bool = true

# Optional: Visual feedback when collected (scale animation)
@export var animate_on_collect: bool = true

func _ready():
    # Validate pickup_id
    if pickup_id.is_empty():
        push_error("Pickup '%s': pickup_id is empty! Each pickup needs a unique ID." % name)
        return

    # Check if already collected
    if PersistenceManager.is_collected(pickup_id):
        if auto_hide_if_collected:
            _hide_pickup()
    else:
        # Register with PersistenceManager if not already tracked
        if not PersistenceManager.has_object_state(pickup_id):
            PersistenceManager.register_object(pickup_id, {"collected": false})

    # Set the interaction prompt
    interaction_text = interaction_prompt

func _interact(interactor: Node):
    # Don't allow picking up twice
    if PersistenceManager.is_collected(pickup_id):
        return

    # Mark as collected in persistence system
    PersistenceManager.mark_as_collected(pickup_id)

    # Show collected message
    _show_dialogue(collected_message)

    # Optional: Animate collection
    if animate_on_collect:
        _animate_collection()
    else:
        _hide_pickup()

    print("Pickup: '%s' collected" % pickup_id)

func _animate_collection():
    # Simple scale-up and fade animation
    var tween = create_tween()
    tween.set_parallel(true)
    tween.set_ease(Tween.EASE_OUT)
    tween.set_trans(Tween.TRANS_BACK)

    # Scale up
    tween.tween_property(self, "scale", scale * 1.5, 0.3)

    # After animation, hide
    tween.chain().tween_callback(_hide_pickup)

func _hide_pickup():
    # Hide the pickup (keep in tree for interactable system)
    visible = false
    # Disable collision so raycast doesn't detect it
    if get_node_or_null("CollisionShape3D"):
        $CollisionShape3D.disabled = true

func _show_dialogue(text: String):
    # Use the dialogue system if available
    if has_node("/root/DialogueUI"):
        get_node("/root/DialogueUI").show_dialogue(text)
    else:
        # Fallback: just print to console
        print("Pickup dialogue: %s" % text)
