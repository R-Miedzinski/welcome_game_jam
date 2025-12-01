class_name GridController
extends Node

signal is_initialized(grid_size: Vector2i, tile_size: float)

@export var grid_size: Vector2i = Vector2i(6, 12)
@export var tile_size: float = 2.0
var effects_map: Dictionary[Vector2i, Effect] = {}

@onready var grid_map: GridMap = %GridMap

func coordinates_to_position(coord: Vector2i) -> Vector3:
    var z = (coord.x - float(grid_size.x) / 2) * tile_size
    var x = (coord.y) * tile_size
    return Vector3(x, 0, z)

func position_to_coordinates(pos: Vector3) -> Vector2i:
    var x = int(round((pos.z) / tile_size + float(grid_size.x) / 2) - (tile_size - 1) / 2)
    var y = int(round((pos.x) / tile_size) - (tile_size - 1) / 2)
    return Vector2i(x, y)

func get_effect_for_tile(coord: Vector2i):
    return effects_map.get(coord)

func _ready() -> void:
    _initialize_grid()
    emit_signal("is_initialized", grid_size, tile_size)

func _initialize_grid() -> void:
    var labels_container = Node3D.new()

    grid_map.position = Vector3(
        (tile_size - 1) / 2,
        -0.4,
        - float(grid_size.x) / 2 * tile_size + (tile_size - 1) / 2
        )

    for x in range(grid_size.x):
        for z in range(grid_size.y):
            var tile_position = Vector3(z * tile_size, 0, x * tile_size)
            grid_map.set_cell_item(tile_position, 0)
            
            var label = Label3D.new()
            label.text = "%d,%d" % [x, z]
            label.position = tile_position + Vector3(0, 0.5, (tile_size - 1) / 2)
            label.modulate = Color(1, 0, 0)
            label.font_size = 32
            labels_container.add_child(label)
    add_child(labels_container)
