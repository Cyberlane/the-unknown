# scripts/autoload/dimension_manager.gd
extends Node

signal dimension_changed(new_dimension)

enum Dimension {
    NORMAL,
    VIKING,
    AZTEC,
    NIGHTMARE
}

var current_dimension: Dimension = Dimension.NORMAL:
    set(value):
        if current_dimension != value:
            current_dimension = value
            dimension_changed.emit(current_dimension)

# Set to true to prevent dimension switching (used by DimensionGate passive mode)
var dimension_locked: bool = false

func switch_to(dimension_index: int):
    # Check if dimension switching is locked
    if dimension_locked:
        print("Dimension switch blocked - currently in a locked zone")
        return

    if dimension_index in Dimension.values():
        current_dimension = dimension_index as Dimension
        print("Dimension switch to: ", Dimension.keys()[current_dimension])
