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

func switch_to(dimension_index: int):
    if dimension_index in Dimension.values():
        current_dimension = dimension_index as Dimension
        print("Dimension switch to: ", Dimension.keys()[current_dimension])
