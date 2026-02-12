extends Node
## EventBus - Central signal hub for decoupled communication
## All major game events are emitted and listened to here to avoid hard dependencies

# ===== PLAYER SIGNALS =====
signal player_health_changed(new_health: float, max_health: float)
signal player_sanity_changed(new_sanity: float, max_sanity: float)
signal player_died(cause: String)
signal player_position_changed(position: Vector3)
signal player_state_changed(new_state: String)

# ===== DIMENSION SIGNALS =====
signal dimension_change_requested(dimension_id: String)
signal dimension_changed(from_dimension: String, to_dimension: String)
signal pre_dimension_change(to_dimension: String)
signal dimension_transition_started(to_dimension: String)
signal dimension_transition_completed(dimension: String)

# ===== INTERACTION SIGNALS =====
signal interaction_prompt_shown(text: String)
signal interaction_prompt_hidden()
signal interactable_focused(interactable: Node)
signal interactable_unfocused(interactable: Node)
signal interaction_performed(interactable: Node)

# ===== COMBAT SIGNALS =====
signal enemy_spawned(enemy: Node)
signal enemy_died(enemy: Node, killer: Node)
signal enemy_damaged(enemy: Node, damage: float, damage_type: String)
signal player_attacked(target: Node, damage: float)

# ===== GOD SYSTEM SIGNALS =====
signal god_offer_received(god_name: String, offer_data: Dictionary)
signal god_offer_accepted(god_name: String)
signal god_offer_declined(god_name: String)
signal god_favour_changed(god_name: String, new_favour: float)
signal god_betrayed(betrayed_god: String, receiving_god: String)
signal god_punishment_applied(god_name: String, punishment_type: String)
signal god_reward_applied(god_name: String, reward_type: String)

# ===== TRAP SIGNALS =====
signal trap_triggered(trap: Node, victim: Node)
signal trap_reset(trap: Node)

# ===== INVENTORY SIGNALS =====
signal item_picked_up(item_name: String, item_data: Dictionary)
signal item_used(item_name: String)
signal item_dropped(item_name: String)
signal inventory_changed()

# ===== LEVEL SIGNALS =====
signal level_loaded(level_name: String)
signal level_generation_started(seed_value: int)
signal level_generation_completed(level_data: Dictionary)
signal room_entered(room_id: String)
signal room_exited(room_id: String)

# ===== UI SIGNALS =====
signal ui_menu_opened(menu_name: String)
signal ui_menu_closed(menu_name: String)
signal debug_overlay_toggled(visible: bool)

# ===== EDITOR SIGNALS =====
signal grid_visibility_changed(is_visible: bool)
signal editor_mode_changed(is_active: bool)
signal block_placed(block_type: String, position: Vector3)
signal block_deleted(block_id: String)
signal editor_selection_changed(selected_item: Node)

# ===== SAVE/LOAD SIGNALS =====
signal game_saved(save_slot: int)
signal game_loaded(save_slot: int)
signal permadeath_save_created(level: int, position: Vector3)

# ===== AUDIO SIGNALS =====
signal audio_effect_requested(effect_name: String, position: Vector3)
signal music_track_changed(track_name: String)
signal ambient_sound_changed(sound_name: String)

func _ready() -> void:
	print("EventBus initialized")
