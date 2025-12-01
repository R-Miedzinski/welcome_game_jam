class_name EnemiesController
extends Node3D

@onready var grid_controller: GridController = %Grid
@onready var tower_controller: TowerController = %Tower

var enemies_map: Dictionary[Vector2i, Enemy] = {}

func spawn_enemy_at_position(pos: Vector2i, enemy_scene: PackedScene, modifier: Dictionary) -> void:
    if enemies_map.has(pos):
        print("An enemy already exists at position %s" % pos)
        return

    var enemy_instance: Enemy = enemy_scene.instantiate() as Enemy
    enemy_instance.position_in_grid = pos

    self._center_on_tile(enemy_instance)
    enemy_instance.position += Vector3(- (grid_controller.tile_size - enemy_instance.dimensions.x) / 2, 0, 0)
    enemies_map[pos] = enemy_instance
    
    enemy_instance.connect("deal_damage", tower_controller._on_take_damage)
    add_child(enemy_instance)
    print("Spawned enemy at position %s" % pos)
  
func remove_enemy_at_position(pos: Vector2i) -> void:
    if enemies_map.has(pos):
        var enemy_instance: Enemy = enemies_map[pos]
        enemies_map.erase(pos)
        enemy_instance.queue_free()
        print("Removed enemy at position %s" % pos)
    else:
        print("No enemy found at position %s to remove" % pos)

func move_enemy_from_to(old_pos: Vector2i, new_pos: Vector2i) -> bool:
    if enemies_map.has(new_pos):
        print("Cannot move enemy to %s; position already occupied" % new_pos)
        return false

    if enemies_map.has(old_pos):
        var enemy_instance: Enemy = enemies_map[old_pos]
        enemies_map.erase(old_pos)

        if new_pos.y < 0:
            enemy_instance.attack_player()
            enemy_instance.queue_free()
            print("Enemy at position %s has exited the grid and is removed" % old_pos)
            return true

        var effect: Effect = grid_controller.get_effect_for_tile(new_pos)
        if effect != null:
            effect.apply_effect(enemy_instance)

        enemies_map[new_pos] = enemy_instance
        print("Moved enemy from %s to %s" % [old_pos, new_pos])
        return true
    else:
        print("No enemy found at position %s to move" % old_pos)
        return false

func move_enemies() -> void:
  for pos in enemies_map.keys():
      var enemy_instance: Enemy = enemies_map[pos]
      if !enemy_instance.is_moving:
        var enemy_moved = self.move_enemy_from_to(pos, Vector2i(pos.x, pos.y + enemy_instance.speed))
        if enemy_moved:
            enemy_instance.move(grid_controller.tile_size)
      
func _center_on_tile(enemy: Enemy) -> void:
    var target_position: Vector3 = grid_controller.coordinates_to_position(enemy.position_in_grid)
    target_position += Vector3(
      (grid_controller.tile_size - enemy.dimensions.x) / 2,
      enemy.dimensions.y / 2,
      (grid_controller.tile_size - enemy.dimensions.z) / 2
    )
    enemy.position = target_position

func _on_spawners_spawn_enemy(pos: Vector2i, enemy_scene: PackedScene, modifier: Dictionary) -> void:
    spawn_enemy_at_position(pos, enemy_scene, modifier)

func _process(delta: float) -> void:
    move_enemies()
