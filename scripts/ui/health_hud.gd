# scripts/ui/health_hud.gd
extends Control

var health: int = 100  # Default value, will be updated by the health system

func update_health(new_health: int):
    health = new_health
    get_node("HealthBar").value = health / MAX_HEALTH  # Update the UI bar

ready():
    EventBus.connect("health_changed", self, "update_health")  # Listen for health changes
