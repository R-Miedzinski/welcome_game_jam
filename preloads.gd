extends Node

# Enemy Scenes
@export var AVAILABLE_ENEMIES = [
    preload("res://enemies/gnome/gnome.tscn"),
    preload("res://enemies/frog/frog.tscn"),
    preload("res://enemies/mushroom/mushroom.tscn"),
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

# Effects
@export var TARGET = preload("res://grid/vfx/Aim_VFX.tscn")
@export var AOE_TILES: Dictionary = {
    "Ice": preload("res://grid/vfx/Frozen_Vfx.tscn"),
    "Acid": preload("res://grid/vfx/Acid_Vfx.tscn"),
}
@export var EFFECT_SFX: Dictionary = {
    "Fire": preload("res://effects/dot/ogień.wav"),
    "Water": preload("res://effects/slow/woda.wav"),
    "Ice": preload("res://effects/slow_ground/lód.wav"),
    "Acid": preload("res://effects/dot_ground/kwas.wav"),
    "Stone": preload("res://effects/stun/pertyfikacja.wav"),
}