# scripts/autoload/choice_manager.gd
extends Node

# Signals for tracking changes
signal alignment_changed(new_value: int)
signal viking_trust_changed(new_value: int)
signal aztec_trust_changed(new_value: int)
signal nightmare_trust_changed(new_value: int)

# Core alignment score (-100 to 100)
# Negative = darker choices, Positive = lighter choices
var alignment_score: int = 0:
    set(value):
        alignment_score = clampi(value, -100, 100)
        alignment_changed.emit(alignment_score)
        print("Alignment Score: ", alignment_score)

# Dimension-specific trust values (0 to 100)
var viking_trust: int = 0:
    set(value):
        viking_trust = clampi(value, 0, 100)
        viking_trust_changed.emit(viking_trust)
        print("Viking Trust: ", viking_trust)

var aztec_trust: int = 0:
    set(value):
        aztec_trust = clampi(value, 0, 100)
        aztec_trust_changed.emit(aztec_trust)
        print("Aztec Trust: ", aztec_trust)

var nightmare_trust: int = 0:
    set(value):
        nightmare_trust = clampi(value, 0, 100)
        nightmare_trust_changed.emit(nightmare_trust)
        print("Nightmare Trust: ", nightmare_trust)

# Choice tracking
var choices_made: Dictionary = {}
var total_choices: int = 0

func _ready():
    print("ChoiceManager initialized")

# Main methods for modifying values
func modify_alignment(amount: int, reason: String = ""):
    alignment_score += amount
    _log_choice("alignment", amount, reason)

func modify_viking_trust(amount: int, reason: String = ""):
    viking_trust += amount
    _log_choice("viking_trust", amount, reason)

func modify_aztec_trust(amount: int, reason: String = ""):
    aztec_trust += amount
    _log_choice("aztec_trust", amount, reason)

func modify_nightmare_trust(amount: int, reason: String = ""):
    nightmare_trust += amount
    _log_choice("nightmare_trust", amount, reason)

# Record a choice for tracking
func record_choice(choice_id: String, data: Dictionary = {}):
    total_choices += 1
    choices_made[choice_id] = {
        "timestamp": Time.get_ticks_msec(),
        "data": data
    }
    print("Choice recorded: ", choice_id)

func has_made_choice(choice_id: String) -> bool:
    return choices_made.has(choice_id)

func get_choice_data(choice_id: String) -> Dictionary:
    if choices_made.has(choice_id):
        return choices_made[choice_id].data
    return {}

# Helper to determine dominant alignment
func get_alignment_type() -> String:
    if alignment_score > 50:
        return "Heroic"
    elif alignment_score > 20:
        return "Good"
    elif alignment_score > -20:
        return "Neutral"
    elif alignment_score > -50:
        return "Dark"
    else:
        return "Evil"

# Helper to get trust level description
func get_trust_level(trust_value: int) -> String:
    if trust_value >= 80:
        return "Revered"
    elif trust_value >= 60:
        return "Trusted"
    elif trust_value >= 40:
        return "Friendly"
    elif trust_value >= 20:
        return "Neutral"
    else:
        return "Suspicious"

# Debug/stats display
func print_stats():
    print("\n=== Choice Manager Stats ===")
    print("Alignment Score: ", alignment_score, " (", get_alignment_type(), ")")
    print("Viking Trust: ", viking_trust, " (", get_trust_level(viking_trust), ")")
    print("Aztec Trust: ", aztec_trust, " (", get_trust_level(aztec_trust), ")")
    print("Nightmare Trust: ", nightmare_trust, " (", get_trust_level(nightmare_trust), ")")
    print("Total Choices: ", total_choices)
    print("===========================\n")

# Internal logging
func _log_choice(stat_name: String, amount: int, reason: String):
    var sign = "+" if amount >= 0 else ""
    var log_msg = "[ChoiceManager] %s %s%d" % [stat_name, sign, amount]
    if not reason.is_empty():
        log_msg += " (%s)" % reason
    print(log_msg)

# Save/Load support (for future implementation)
func get_save_data() -> Dictionary:
    return {
        "alignment_score": alignment_score,
        "viking_trust": viking_trust,
        "aztec_trust": aztec_trust,
        "nightmare_trust": nightmare_trust,
        "choices_made": choices_made,
        "total_choices": total_choices
    }

func load_save_data(data: Dictionary):
    alignment_score = data.get("alignment_score", 0)
    viking_trust = data.get("viking_trust", 0)
    aztec_trust = data.get("aztec_trust", 0)
    nightmare_trust = data.get("nightmare_trust", 0)
    choices_made = data.get("choices_made", {})
    total_choices = data.get("total_choices", 0)
    print("ChoiceManager: Loaded save data")
