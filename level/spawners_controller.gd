class_name SpawnersController
extends Node3D

@export var spawner_timer_interval: float = 3.0
var grid_size: Vector2i
var tile_size: float

@onready var enemies_controller: EnemiesController = %Enemies
@onready var spawner_timer: Timer = %SpawnTimer

signal spawn_enemy(position: Vector2i, enemy_scene: PackedScene, modifier: Dictionary)

func spawn_enemy_at_random() -> void:
    var row_index = randi() % self.grid_size.x
    var enemy_scene: PackedScene = self.get_random_enemy()
    emit_signal("spawn_enemy", Vector2i(row_index, self.grid_size.y), enemy_scene, {})
    self.spawner_timer.start(self.spawner_timer_interval)

func get_random_enemy() -> PackedScene:
    var probabilities = Constants.ENEMY_SPAWN_PROBABILITIES
    var total_weight = 0
    for weight in probabilities.values():
        total_weight += weight

    var random_value = randi() % total_weight
    var cumulative_weight = 0

    for enemy_type in probabilities.keys():
        cumulative_weight += probabilities[enemy_type]
        if random_value < cumulative_weight:
            return Preloads.AVAILABLE_ENEMIES[enemy_type]

    return Preloads.AVAILABLE_ENEMIES[0] # Fallback

func _ready() -> void:
    self.spawner_timer.start(self.spawner_timer_interval)

func _initialize_spawners(_grid_size: Vector2i, _tile_size: float) -> void:
    self.grid_size = _grid_size
    self.tile_size = _tile_size
