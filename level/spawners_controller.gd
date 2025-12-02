class_name SpawnersController
extends Node3D

@onready var enemies_controller: EnemiesController = %Enemies
var grid_size: Vector2i
var tile_size: float

signal spawn_enemy(position: Vector2i, enemy_scene: PackedScene, modifier: Dictionary)

func spawn_enemy_at_random() -> void:
    var row_index = randi() % self.grid_size.x
    var enemy_scene: PackedScene = preload("res://enemies/base_enemy/base_enemy.tscn")
    emit_signal("spawn_enemy", Vector2i(row_index, self.grid_size.y), enemy_scene, {})

func _initialize_spawners(_grid_size: Vector2i, _tile_size: float) -> void:
    self.grid_size = _grid_size
    self.tile_size = _tile_size
