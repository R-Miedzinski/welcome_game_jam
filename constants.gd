extends Node

# Grid Configuration
@export var TILE_SIZE: float = 2.0
@export var GRID_SIZE: Vector2i = Vector2i(6, 11)
@export var TILE_HEIGHT: float = 0.4
@export var EFFECT_TICK_DURATION: float = 0.05
enum MovementDirection {
    LEFT = 1,
    RIGHT = -1
}

# Potion Configuration
@export var MAX_THROW_TIME: float = 0.5
@export var THROW_TIME_SCALING: float = 0.1

# Spawner Configuration
@export var ENEMY_SPAWN_INTERVAL: float = 4.0
@export var ENEMY_SPAWN_PROBABILITIES: Dictionary[int, int] = {
    0: 5, # Gnome
    1: 3, # Frog
    # 2: 0.2 # Mushroom
}

# Conveyor Configuration
@export var COMPONENT_SPAWN_INTERVAL: float = 2.0
@export var CONVEYOR_CAPACITY: int = 10
@export var SOLID_FACTOR: int = 4

# Cauldron Configuration
@export var CAULDRON_CAPACITY: int = 5
