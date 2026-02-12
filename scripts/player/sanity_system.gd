# scripts/player/sanity_system.gd
extends Node3D

var EventBus = preload("res://scripts/autoloads/event_bus.gd")  # Load the event bus autoload

const MAX_SANITY = 100
var sanity: int = 100

func consume_sanity(amount: int):
    if amount < 0:<｜begin▁of▁sentence｜>
        return  # Negative consumption is gain, not supported yet.
    
    sanity -= amount
    EventBus.emit("sanity_changed", sanity)  # Emit a signal to update the HUD

    if sanity <= 0:
        die()

func regain_sanity(amount: int):
    if amount < 0:
        return  # Negative gain is consumption, not supported yet.
    
    sanity += amount
    sanity = clamp(sanity, 0, MAX_SANITY)
    EventBus.emit("sanity_changed", sanity)  # Emit a signal to update the HUD

func die():
    print("Player has lost all sanity.")
