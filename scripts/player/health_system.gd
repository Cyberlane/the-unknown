# scripts/player/health_system.gd
extends Node3D

var EventBus = preload("res://scripts/autoloads/event_bus.gd")  # Load the event bus autoload

const MAX_HEALTH = 100
var health: int = 100

func take_damage(amount: int):
    if amount < 0:
        return  # Negative damage is healing, not supported yet.
    
    health -= amount
    EventBus.emit("health_changed", health)  # Emit a signal to update the HUD

    if health <= 0:
        die()

func heal(amount: int):
    if amount < 0:
        return  # Negative healing is damage, not supported yet.
    
    health += amount
    health = clamp(health, 0, MAX_HEALTH)
    EventBus.emit("health_changed", health)  # Emit a signal to update the HUD

func die():
    print("Player has died.")
