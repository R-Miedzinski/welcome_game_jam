extends Node

# Menu Texts
@export var MAIN_MENU_TITLE: String = "Potion Defense"
@export var MAIN_MENU_START_BUTTON: String = "Start Game"
@export var MAIN_MENU_EXIT_BUTTON: String = "Exit Game"
@export var PAUSE_MENU_TITLE: String = "Game Paused"
@export var GAME_OVER_TITLE: String = "Game Over"
@export var PAUSE_MENU_RESUME_BUTTON: String = "Resume"
@export var PAUSE_MENU_MAIN_MENU_BUTTON: String = "Main Menu"
@export var PAUSE_MENU_EXIT_BUTTON: String = "Exit Game"

# SFX Buses
@export var SFX_BUS_NAME: String = "SFX"
@export var MUSIC_BUS_NAME: String = "Soundtrack"
@export var MASTER_BUS_NAME: String = "Master"
@export var VOICELINE_BUS_NAME: String = "Voicelines"

# Grid Configuration
@export var TILE_SIZE: float = 2.0
@export var GRID_SIZE: Vector2i = Vector2i(6, 11)
@export var TILE_HEIGHT: float = 0.4
@export var EFFECT_TICK_DURATION: float = 0.05
@export var GRAVITY: float = -9.8
enum MovementDirection {
    LEFT = 1,
    RIGHT = -1,
    UP = 2,
    DOWN = -2
}

# Potion Configuration
@export var MAX_THROW_TIME: float = 0.5
@export var THROW_TIME_SCALING: float = 0.1
@export var FLAT_DAMAGE_SCALING: Dictionary[int, int] = {
    1: 0,
    2: 1,
    3: 2,
    4: 3,
}
enum EffectTypes {
    DMG,
    DOT,
    DOT_GROUND,
    SLOW,
    SLOW_GROUND,
    RESET,
    MOVE,
    STUN
}

# Spawner Configuration
@export var ENEMY_SPAWN_INTERVAL: float = 6.0
@export var ENEMY_SPAWN_PROBABILITIES: Dictionary[int, int] = {
    0: 6, # Gnome
    1: 3, # Frog
    2: 2 # Mushroom
}

# Conveyor Configuration
@export var COMPONENT_SPAWN_INTERVAL: float = 2.0
@export var CONVEYOR_CAPACITY: int = 10
@export var SOLID_FACTOR: int = 4 # rand % SOLID_FACTOR == 0 -> solid component

# Cauldron Configuration
@export var CAULDRON_CAPACITY: int = 4
