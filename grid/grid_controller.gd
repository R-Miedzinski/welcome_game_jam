class_name GridController
extends Node


signal grid_is_initialized(grid_size: Vector2i, tile_size: float)
signal effect_tick(tile_coord: Vector2i, effects: Array)

@export var grid_size: Vector2i = Vector2i(6, 12)
@export var tile_size: float = 2.0
@export var tile_height: float = 0.4
var effects_map: Dictionary[Vector2i, Array] = {}

@export var tick_duration: float = 1.0

@onready var grid_map: GridMap = %GridMap
@onready var effects_clock: Timer = %EffectsTick

func coordinates_to_position(coord: Vector2i) -> Vector3:
    var z = (coord.x - float(grid_size.x) / 2) * tile_size
    var x = (coord.y) * tile_size
    return Vector3(x, 0, z)

func position_to_coordinates(pos: Vector3) -> Vector2i:
    var rescaled_pos = pos

    var x = rescaled_pos.z / tile_size + float(grid_size.x) / 2
    var y = rescaled_pos.x / tile_size

    return Vector2i(floor(x), floor(y))

func highlight_tile(coord: Vector2i) -> void:
    grid_map.set_cell_item(Vector3i(coord.y * tile_size, 0, coord.x * tile_size), 1)

func unhighlight_tile(coord: Vector2i) -> void:
    grid_map.set_cell_item(Vector3i(coord.y * tile_size, 0, coord.x * tile_size), 0)

func get_effects_for_tile(coord: Vector2i):
    return self.effects_map.get(coord)

func _ready() -> void:
    _initialize_grid()
    emit_signal("grid_is_initialized", grid_size, tile_size)

func _on_effect_tick() -> void:
    for tile_coord in self.effects_map.keys():
        var effects: Array = self.effects_map[tile_coord] as Array
        emit_signal("effect_tick", tile_coord, effects)
        
        var effects_to_remove: Array = []
        for idx in range(effects.size()):
            effects[idx].duration -= self.tick_duration
            if effects[idx].duration <= 0:
                effects_to_remove.append(idx)

        effects_to_remove.sort()
        effects_to_remove.reverse()
        for idx in effects_to_remove:
            effects.remove_at(idx)
        self.effects_map[tile_coord] = effects

    self.effects_clock.start()

func _on_potion_thrown(potion: Potion, tile_coord: Vector2i, origin: Vector3) -> void:
    var potion_instance: Potion = potion as Potion
    potion_instance.position = origin
    self.get_tree().get_current_scene().add_child(potion_instance)

    var target_position: Vector3 = coordinates_to_position(tile_coord) + Vector3(
      (tile_size) / 2,
      grid_map.position.y,
      (tile_size) / 2
    )

    var tween = get_tree().create_tween()
    tween.tween_property(potion_instance, "position", target_position + Vector3(0, 1.0, 0), 0.5)

    tween.finished.connect(
      func() -> void:
        potion_instance.queue_free()
        var effects_to_apply = potion.effects.duplicate(true)
        for effect in effects_to_apply:
            effect.duration = potion.duration

        for x_offset in range(-potion.size + 1, potion.size):
            for y_offset in range(-potion.size + 1, potion.size):
                var distance = abs(x_offset) + abs(y_offset)
                if distance < potion.size:
                    var affected_tile = Vector2i(tile_coord.x + x_offset, tile_coord.y + y_offset)
                    if affected_tile.x >= 0 and affected_tile.x < grid_size.x \
                    and affected_tile.y >= 0 and affected_tile.y < grid_size.y:
                        if self.effects_map.has(affected_tile):
                            self.effects_map[affected_tile] += effects_to_apply.duplicate(true)
                        else:
                            self.effects_map[affected_tile] = effects_to_apply.duplicate(true)
    )

func _initialize_grid() -> void:
    grid_map.position = Vector3(
        (tile_size - 1) / 2,
        - self.tile_height,
        - float(grid_size.x) / 2 * tile_size + (tile_size - 1) / 2
        )

    for x in range(grid_size.x):
        for z in range(grid_size.y):
            var tile_position = Vector3(z * tile_size, 0, x * tile_size)
            grid_map.set_cell_item(tile_position, 0)

    self.effects_clock.wait_time = self.tick_duration
    self.effects_clock.start()
