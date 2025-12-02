class_name EnemiesController
extends Node3D

@onready var grid_controller: GridController = %Grid
@onready var tower_controller: TowerController = %Tower

var enemies_map = EnemiesMap.new()


func spawn_enemy_at_position(pos: Vector2i, enemy_scene: PackedScene, modifier: Dictionary) -> void:
    # if self.enemies_map.has(pos):
    #     print("An enemy already exists at position %s" % pos)
    #     return
    var enemy_instance: Enemy = enemy_scene.instantiate() as Enemy
    enemy_instance.position_in_grid = pos

    self._center_on_tile(enemy_instance)
    enemy_instance.position += Vector3(- (self.grid_controller.tile_size - enemy_instance.dimensions.x) / 2, 0, 0)
    self.enemies_map.register_enemy_at_position(pos, enemy_instance)
    
    enemy_instance.connect("deal_damage", self.tower_controller._on_take_damage)
    enemy_instance.connect("enemy_defeated", self._on_enemy_defeated)
    add_child(enemy_instance)

func register_enemy_at_position(pos: Vector2i, enemy_instance: Enemy) -> void:
    self.enemies_map.register_enemy_at_position(pos, enemy_instance)

func unregister_enemy_at_position(pos: Vector2i, idx: int = 0) -> void:
    self.enemies_map.unregister_enemy_at_position(pos, idx)

func get_enemy_at_position(pos: Vector2i, idx: int = 0) -> Enemy:
    return self.enemies_map.get_enemy_at_position(pos, idx)

func remove_enemy_at_position(pos: Vector2i, idx: int = 0) -> void:
    self.enemies_map.remove_enemy_at_position(pos, idx)

func move_enemy_from_to(old_pos: Vector2i, new_pos: Vector2i, idx: int = 0) -> bool:
    if self.enemies_map.has(old_pos) and self.enemies_map.map[old_pos].size() > idx:
        var enemy_instance: Enemy = self.enemies_map.get_enemy_at_position(old_pos, idx)
        self.enemies_map.unregister_enemy_at_position(old_pos, idx)

        if new_pos.y < 0:
            enemy_instance.attack_player()
            enemy_instance.queue_free()
            print("Enemy at position %s has exited the grid and is removed" % old_pos)
            return true

        self.enemies_map.register_enemy_at_position(new_pos, enemy_instance)
        return true
    else:
        print("No enemy found at position %s to move" % old_pos)
        return false

func move_enemies() -> void:
  for pos in self.enemies_map.map.keys():
      var enemies_at_position: Array = self.enemies_map.get_enemies_at_position(pos)
      for idx in range(enemies_at_position.size() - 1, -1, -1):
        var enemy_instance: Enemy = enemies_at_position[idx]
        if !enemy_instance.is_moving:
            var new_pos: Vector2i = Vector2i(pos.x, pos.y + enemy_instance.speed)
            var enemy_moved = self.move_enemy_from_to(pos, new_pos, idx)
            if enemy_moved:
                enemy_instance.move(new_pos, self.grid_controller.tile_size)
                enemy_instance.position_in_grid = new_pos
      
func _center_on_tile(enemy: Enemy) -> void:
    var target_position: Vector3 = self.grid_controller.coordinates_to_position(enemy.position_in_grid)
    target_position += Vector3(
      (self.grid_controller.tile_size - enemy.dimensions.x) / 2,
      enemy.dimensions.y / 2,
      (self.grid_controller.tile_size - enemy.dimensions.z) / 2
    )
    enemy.position = target_position

func _process(delta: float) -> void:
    move_enemies()

    self.enemies_map.process_removals()

func _on_spawners_spawn_enemy(pos: Vector2i, enemy_scene: PackedScene, modifier: Dictionary) -> void:
    spawn_enemy_at_position(pos, enemy_scene, modifier)

func _on_effect_tick(tile_coord: Vector2i, effects: Array) -> void:
    if effects.size() == 0:
        return

    var enemies_in_tile: Array = self.enemies_map.get_enemies_at_position(tile_coord)
    var enemies_exiting_tile: Array = self.enemies_map.get_enemies_at_position(Vector2i(tile_coord.x, tile_coord.y - 1)).filter(
        func(enemy_instance: Enemy) -> bool:
            return (
                self.grid_controller.position_to_coordinates(enemy_instance.position + Vector3(enemy_instance.dimensions.x, 0, 0)).y == tile_coord.y
            and !enemies_in_tile.has(enemy_instance)
            )
    )

    var affected_enemies = enemies_in_tile + enemies_exiting_tile
    for enemy_instance in affected_enemies:
        for effect in effects:
            (effect as Effect).apply(enemy_instance)

func _on_enemy_defeated(position_in_grid: Vector2i, idx: int) -> void:
    remove_enemy_at_position(position_in_grid, idx)

class EnemiesMap:
    var map: Dictionary[Vector2i, Array] = {}
    var marked_for_removal: Array[Vector3i] = []

    func register_enemy_at_position(pos: Vector2i, enemy_instance: Enemy) -> void:
        if map.has(pos):
            map[pos].append(enemy_instance)
        else:
            map[pos] = [enemy_instance]

        enemy_instance.idx_in_position = map[pos].size() - 1

    func unregister_enemy_at_position(pos: Vector2i, idx: int = 0) -> Enemy:
        if map.has(pos) and map[pos].size() > idx:
            var enemy_instance: Enemy = map[pos].pop_at(idx)
            if map[pos].size() == 0:
                map.erase(pos)

            enemy_instance.idx_in_position = -1
            return enemy_instance
        return null

    func get_enemy_at_position(pos: Vector2i, idx: int = 0) -> Enemy:
        if map.has(pos) and map[pos].size() > idx:
            return map[pos][idx]
        return null

    func remove_enemy_at_position(pos: Vector2i, idx: int = 0) -> void:
        if map.has(pos) and map[pos].size() > idx:
            marked_for_removal.append(Vector3i(pos.x, pos.y, idx))

    func process_removals() -> void:
        while marked_for_removal.size() > 0:
            var removal: Vector3i = marked_for_removal.pop_back()
            var pos = Vector2i(removal.x, removal.y)
            var idx = int(removal.z)
            if map.has(pos) and map[pos].size() > idx:
                var enemy_instance: Enemy = map[pos].pop_at(idx)
                if map[pos].size() == 0:
                    map.erase(pos)
                enemy_instance.animation_player.queue("death")

    func get_enemies_at_position(pos: Vector2i) -> Array:
        if map.has(pos):
            return map[pos] as Array
        return []

    func has(pos: Vector2i) -> bool:
        return map.has(pos) and map[pos].size() > 0

    func get_all_enemies_count() -> int:
        var total: int = 0
        for pos in map.keys():
            total += map[pos].size()
        return total
