extends Node

# Enemy Scenes
@export var AVAILABLE_ENEMIES = [
    preload("res://enemies/base_enemy/base_enemy.tscn"),
    preload("res://enemies/jumping_enemy/jumping_enemy.tscn"),
    # preload("res://enemies/mushroom/mushroom.tscn"),
]

# Components
@export var AVAILABLE_LIQUID_COMPONENTS = [
    preload("res://components/liquid/fire.tres"),
    preload("res://components/liquid/water.tres"),
    preload("res://components/liquid/acid.tres"),
    preload("res://components/liquid/ice.tres"),
    preload("res://components/liquid/stone.tres"),
]

@export var AVAILABLE_SOLID_COMPONENTS = [
    preload("res://components/solid/range.tres"),
    preload("res://components/solid/time.tres"),
    preload("res://components/solid/move_left.tres"),
    preload("res://components/solid/reset.tres"),
]

# Base Damages
@export var BASE_DAMAGE_EFFECTS: Array[Effect] = [
    preload("res://effects/damage/damage_1.tres"),
    preload("res://effects/damage/damage_2.tres"),
    preload("res://effects/damage/damage_3.tres"),
    preload("res://effects/damage/damage_4.tres"),
]