class_name EnemiesController
extends Node3D

@onready var grid_controller: GridController = %Grid
@onready var tower_controller: TowerController = %Tower

var enemies_map = EnemiesMap.new()
var next_index: int = 0

func spawn_enemy_at_position(pos: Vector2i, enemy_scene: PackedScene, modifier: Dictionary) -> void:
    var enemy_instance: Enemy = enemy_scene.instantiate() as Enemy
    enemy_instance.front_position_in_grid = pos + Vector2i(0, 1)
    enemy_instance.back_position_in_grid = pos + Vector2i(0, 1)
    enemy_instance.idx_in_position = self.next_index
    self.next_index += 1

    self._center_on_tile(enemy_instance)
    enemy_instance.position += Vector3(- (Constants.TILE_SIZE - enemy_instance.dimensions.x - 0.05) / 2, 0, 0)
    self.enemies_map.register_enemy_at_position(pos + Vector2i(0, 1), enemy_instance)

    enemy_instance.connect("deal_damage", self.tower_controller._on_take_damage)
    enemy_instance.connect("enemy_attacked_player", self._on_enemy_dealt_damage)
    enemy_instance.connect("enemy_defeated", self._on_enemy_defeated)
    self.grid_controller.effects_clock.connect("timeout", enemy_instance._on_effect_tick)
    add_child(enemy_instance)

func move_enemy_from_to(old_pos: Vector2i, new_pos: Vector2i, idx: int = 0) -> bool:
    if self.enemies_map.has(old_pos, idx):
        var enemy_instance: Enemy = self.enemies_map.get_enemy_at_position(old_pos, idx)
        self.enemies_map.unregister_enemy_at_position(old_pos, idx)

        self.enemies_map.register_enemy_at_position(new_pos, enemy_instance)
        return true
    else:
        print("No enemy found at position %s to move" % old_pos)
        self.get_tree().paused = true
        return false
      
func _center_on_tile(enemy: Enemy) -> void:
    var target_position: Vector3 = self.grid_controller.coordinates_to_position(enemy.front_position_in_grid)
    target_position += Vector3(
      (Constants.TILE_SIZE - enemy.dimensions.x) / 2,
      enemy.dimensions.y / 2,
      (Constants.TILE_SIZE - enemy.dimensions.z) / 2
    )
    enemy.position = target_position

func _process(delta: float) -> void:
    self.enemies_map.process_removals()
    
    for enemy in self.enemies_map.get_all_enemies():
        if enemy == null:
            continue

        enemy.move(delta, Constants.MovementDirection.RIGHT)
        var new_front_pos: Vector2i = self.grid_controller.position_to_coordinates(enemy.position)
        var new_back_pos: Vector2i = self.grid_controller.position_to_coordinates(enemy.position + Vector3(enemy.dimensions.x, 0, 0))
        
        if new_front_pos != enemy.front_position_in_grid:
            self.move_enemy_from_to(enemy.front_position_in_grid, new_front_pos, enemy.idx_in_position)
            enemy.front_position_in_grid = new_front_pos
        if new_back_pos != enemy.back_position_in_grid:
            enemy.back_position_in_grid = new_back_pos
        
func _on_spawners_spawn_enemy(pos: Vector2i, enemy_scene: PackedScene, modifier: Dictionary) -> void:
    spawn_enemy_at_position(pos, enemy_scene, modifier)

func _on_effect_tick(tile_coord: Vector2i, effects: Array, durations: Array) -> void:
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
        if enemy_instance.is_on_ground:
            for idx in range(effects.size()):
                var effect = effects[idx]
                var duration = durations[idx]
                if effect.target_location == Effect.TargetLocation.SELF:
                    if !enemy_instance.self_effects.has(effect.id):
                        (effect as Effect).apply(enemy_instance, duration)
                elif effect.target_location == Effect.TargetLocation.GROUND:
                    (effect as Effect).apply(enemy_instance)

func _on_enemy_defeated(position_in_grid: Vector2i, idx: int) -> void:
    self.enemies_map.remove_enemy_at_position(position_in_grid, idx)

func _on_enemy_dealt_damage(position_in_grid: Vector2i, idx: int) -> void:
    self.enemies_map.remove_enemy_at_position(position_in_grid, idx)

class EnemiesMap:
    var map: Dictionary[Vector3i, Enemy] = {}
    var marked_for_removal: Array[Vector3i] = []

    func register_enemy_at_position(pos: Vector2i, enemy_instance: Enemy) -> void:
        var pos_vec3i = Vector3i(pos.x, pos.y, enemy_instance.idx_in_position)
        if !map.has(pos_vec3i):
            map[pos_vec3i] = enemy_instance
        else:
            print("Warning: Multiple enemies at the same position %s" % pos)

    func unregister_enemy_at_position(pos: Vector2i, idx: int = 0) -> Enemy:
        var pos_vec3i = Vector3i(pos.x, pos.y, idx)
        if map.has(pos_vec3i):
            var enemy_instance: Enemy = map[pos_vec3i]
            map.erase(pos_vec3i)
            return enemy_instance
        return null

    func get_enemy_at_position(pos: Vector2i, idx: int = 0) -> Enemy:
        var pos_vec3i = Vector3i(pos.x, pos.y, idx)
        if map.has(pos_vec3i):
            return map[pos_vec3i]
        return null

    func remove_enemy_at_position(pos: Vector2i, idx: int = 0) -> void:
        var pos_vec3i = Vector3i(pos.x, pos.y, idx)
        if map.has(pos_vec3i):
            marked_for_removal.append(pos_vec3i)

    func process_removals() -> void:
        while marked_for_removal.size() > 0:
            var removal: Vector3i = marked_for_removal.pop_back()
            if map.has(removal):
                var enemy_instance: Enemy = map[removal]
                map.erase(removal)

                if enemy_instance.health > 0:
                    enemy_instance.queue_free()
                else:
                    enemy_instance.animation_player.play("death")

    func get_enemies_at_position(pos: Vector2i) -> Array:
        var enemies: Array = []
        for key in map.keys():
            if key.x == pos.x and key.y == pos.y:
                enemies.append(map[key])
        return enemies

    func has(pos: Vector2i, idx: int) -> bool:
        var pos_vec3i = Vector3i(pos.x, pos.y, idx)
        return map.has(pos_vec3i)

    func get_all_enemies() -> Array:
        var enemies: Array = []
        for pos in map.keys():
            enemies.append(map[pos])
        return enemies

    func get_all_enemies_count() -> int:
        return map.size()
