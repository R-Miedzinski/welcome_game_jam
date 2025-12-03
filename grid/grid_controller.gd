class_name GridController
extends Node

@export var grid_size: Vector2i = Constants.GRID_SIZE
@export var tile_size: float = Constants.TILE_SIZE
@export var tile_height: float = Constants.TILE_HEIGHT
var effects_map: Dictionary[Vector2i, Array] = {}

@export var tick_duration: float = Constants.EFFECT_TICK_DURATION

@onready var grid_map: GridMap = %GridMap
@onready var effects_clock: Timer = %EffectsTick

signal grid_is_initialized(grid_size: Vector2i, tile_size: float)
signal effect_tick(tile_coord: Vector2i, effects: Array, durations: Array)

func coordinates_to_position(coord: Vector2i) -> Vector3:
    var z = (coord.x - float(self.grid_size.x) / 2) * self.tile_size
    var x = (coord.y) * self.tile_size
    return Vector3(x, 0, z)

func position_to_coordinates(pos: Vector3) -> Vector2i:
    var rescaled_pos = pos

    var x = rescaled_pos.z / self.tile_size + float(self.grid_size.x) / 2
    var y = rescaled_pos.x / self.tile_size

    return Vector2i(floor(x), floor(y))

func highlight_tile(coord: Vector2i) -> void:
    self.grid_map.set_cell_item(Vector3i(coord.y * self.tile_size, 0, coord.x * self.tile_size), 1)

func unhighlight_tile(coord: Vector2i) -> void:
    self.grid_map.set_cell_item(Vector3i(coord.y * self.tile_size, 0, coord.x * self.tile_size), 0)

func get_effects_for_tile(coord: Vector2i):
    return self.effects_map.get(coord)

func _ready() -> void:
    self._initialize_grid()
    self.emit_signal("grid_is_initialized", self.grid_size, self.tile_size)

# returns 
# [effects, durations]
func _accumulate_effects(effects_with_duration: Array) -> Array:
    var all_effects: Array = []
    var all_durations: Array = []
    for ewd in effects_with_duration:
        all_effects += ewd.effects
        var durations: Array = []
        durations.resize(ewd.effects.size())
        durations.fill(ewd.duration)
        all_durations += durations
    return [all_effects, all_durations]

func _on_effect_tick() -> void:
    for tile_coord in self.effects_map.keys():
        var all_effects_with_duration: Array = self.effects_map[tile_coord]
        var accumulated_effects: Array = self._accumulate_effects(all_effects_with_duration)
        emit_signal("effect_tick", tile_coord, accumulated_effects[0], accumulated_effects[1])

        var effects_to_remove: Array = []
        for idx in range(all_effects_with_duration.size()):
            all_effects_with_duration[idx].duration -= self.tick_duration
            if all_effects_with_duration[idx].duration <= 0:
                effects_to_remove.append(idx)

        effects_to_remove.sort()
        effects_to_remove.reverse()
        for idx in effects_to_remove:
            all_effects_with_duration.remove_at(idx)
        self.effects_map[tile_coord] = all_effects_with_duration

    self.effects_clock.start()

func _on_potion_thrown(potion: Potion, tile_coord: Vector2i, origin: Vector3) -> void:
    var potion_instance: Potion = potion as Potion
    potion_instance.position = origin
    self.get_tree().get_current_scene().add_child(potion_instance)

    var target_position: Vector3 = coordinates_to_position(tile_coord) + Vector3(
      (self.tile_size) / 2,
      self.grid_map.position.y,
      (self.tile_size) / 2
    )

    var tween = get_tree().create_tween()
    var animation_time: float = min(Constants.MAX_THROW_TIME, Constants.THROW_TIME_SCALING * (tile_coord.y + 1))
    var end_point = target_position + Vector3(0, 1.0, 0)
    # TODO: I would love for the trajectory to be more parabolic
    tween.tween_property(potion_instance, "position", end_point, animation_time)

    tween.finished.connect(
      func() -> void:
        var effects_to_apply: EffectsWithDuration = EffectsWithDuration.new(potion.effects.duplicate(true), potion_instance.duration)
    
        for x_offset in range(-potion.size + 1, potion.size):
            for y_offset in range(-potion.size + 1, potion.size):
                var distance = abs(x_offset) + abs(y_offset)
                if distance < potion.size:
                    var affected_tile = Vector2i(tile_coord.x + x_offset, tile_coord.y + y_offset)
                    if affected_tile.x >= 0 and affected_tile.x < self.grid_size.x \
                    and affected_tile.y >= 0 and affected_tile.y < self.grid_size.y:
                        if self.effects_map.has(affected_tile):
                            self.effects_map[affected_tile].append(effects_to_apply)
                        else:
                            self.effects_map[affected_tile] = [effects_to_apply]

        potion_instance.queue_free()
    )

func _initialize_grid() -> void:
    self.grid_map.position = Vector3(
        (self.tile_size - 1) / 2,
        - self.tile_height,
        - float(self.grid_size.x) / 2 * self.tile_size + (self.tile_size - 1) / 2
        )

    for x in range(self.grid_size.x):
        for z in range(self.grid_size.y):
            var tile_position = Vector3(z * self.tile_size, 0, x * self.tile_size)
            self.grid_map.set_cell_item(tile_position, 0)

    self.effects_clock.wait_time = self.tick_duration
    self.effects_clock.start()

func _on_barrier_collided(entity: Node) -> void:
    print("Entity %s has collided with the end grid barrier." % entity.name)
    entity.attack_player()

class EffectsWithDuration:
    var effects: Array[Effect]
    var duration: float

    func _init(_effects: Array[Effect], _duration: float) -> void:
        self.effects = _effects
        self.duration = _duration