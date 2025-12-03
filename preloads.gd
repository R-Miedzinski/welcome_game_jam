extends Node

# Enemy Scenes
@export var AVAILABLE_ENEMIES = [
    preload("res://enemies/base_enemy/base_enemy.tscn"),
    preload("res://enemies/jumping_enemy/jumping_enemy.tscn"),
    # preload("res://enemies/mushroom/mushroom.tscn"),
]

# Components
@export var AVAILABLE_LIQUID_COMPONENTS = [
    preload("res://components/fire/fire_component_liquid.tres"),
    preload("res://components/water/water_component_liquid.tres"),
]

@export var AVAILABLE_SOLID_COMPONENTS = [
    preload("res://components/fire/fire_component_solid.tres"),
    preload("res://components/water/water_component_solid.tres"),
]