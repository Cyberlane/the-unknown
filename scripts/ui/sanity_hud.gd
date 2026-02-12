# scripts/ui/sanity_hud.gd
extends Control

var sanity: int = 100  # Default value, will be updated by the sanity system

func update_sanity(new_sanity: int):
    sanity = new_sanity
    get_node("SanityMeter").value = sanity / MAX_SANITY  # Update the UI bar

ready():
    EventBus.connect("sanity_changed", self, "update_sanity")  # Listen for sanity changes
