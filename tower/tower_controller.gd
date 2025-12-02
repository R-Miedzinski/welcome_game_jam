class_name TowerController
extends Node3D

@export var health: int = 100
var selected_potion: Resource = null

@onready var shoot_origin: Marker3D = %ThrowOrigin

signal shoot_potion(potion: Potion, target_tile: Vector2i, origin: Vector3)

func shoot(target_tile: Vector2i) -> void:
  if self.selected_potion == null:
      return

  emit_signal("shoot_potion", self.selected_potion.instantiate(), target_tile, self.shoot_origin.global_position)

func _ready() -> void:
  self.selected_potion = preload("res://potions/instant_damage_potion/instant_damage_potion.tscn")

func _on_take_damage(damage: int) -> void:
  print("Tower took %d damage!" % damage)
