# Input Map Configuration

This document describes the input actions needed for Stage 1 of The Unknown.

## How to Configure

1. Open **Project → Project Settings → Input Map** in the Godot editor
2. Add each action listed below
3. Assign the specified keys/buttons

## Required Input Actions

### Movement
| Action Name      | Key/Button       | Description                    |
|------------------|------------------|--------------------------------|
| `move_forward`   | W                | Move forward                   |
| `move_backward`  | S                | Move backward                  |
| `move_left`      | A                | Move left (strafe)             |
| `move_right`     | D                | Move right (strafe)            |
| `jump`           | Space            | Jump                           |
| `sprint`         | Left Shift       | Sprint (hold)                  |
| `crouch`         | Left Ctrl or C   | Toggle crouch                  |

### Interaction
| Action Name      | Key/Button       | Description                    |
|------------------|------------------|--------------------------------|
| `interact`       | E                | Interact with objects          |
| `use_item`       | Left Mouse Button| Use held item / attack         |

### Dimension System (for later stages)
| Action Name              | Key/Button | Description                    |
|--------------------------|------------|--------------------------------|
| `dimension_switch`       | R          | Activate dimension switching   |
| `dimension_normal`       | 1          | Switch to Normal dimension     |
| `dimension_aztec`        | 2          | Switch to Aztec dimension      |
| `dimension_viking`       | 3          | Switch to Viking dimension     |
| `dimension_nightmare`    | 4          | Switch to Nightmare dimension  |

### UI & Debug
| Action Name      | Key/Button       | Description                    |
|------------------|------------------|--------------------------------|
| `ui_cancel`      | Escape           | Pause menu / release mouse     |
| `toggle_debug`   | F3               | Toggle debug overlay           |
| `toggle_editor`  | F4               | Toggle level editor mode       |

### Inventory (for later stages)
| Action Name      | Key/Button       | Description                    |
|------------------|------------------|--------------------------------|
| `inventory`      | Tab or I         | Open inventory                 |
| `quick_slot_1`   | 1 (when not editing) | Quick use slot 1           |
| `quick_slot_2`   | 2 (when not editing) | Quick use slot 2           |
| `quick_slot_3`   | 3 (when not editing) | Quick use slot 3           |
| `quick_slot_4`   | 4 (when not editing) | Quick use slot 4           |

## Mouse Settings

The first-person controller expects:
- **Mouse Mode**: Captured during gameplay
- **Mouse Sensitivity**: 0.003 (adjustable in player script export variables)
- **Y-Axis Invert**: Configurable in player script

## Gamepad Support (Optional - Future)

For future gamepad support, add these mappings:
- Left Stick: Movement
- Right Stick: Camera look
- A/X Button: Jump
- B/Circle: Crouch
- Left Trigger: Sprint
- Right Trigger: Use item/attack
- Y/Triangle: Interact

## Notes

- The `ui_cancel` action (Escape) is used to toggle mouse capture during development
- Actions prefixed with `dimension_` will be used starting in Stage 3
- Actions prefixed with `quick_slot_` and `inventory` will be used starting in Stage 8
- All input actions use the default deadzone (0.5) unless specified otherwise
