class_name TowerController
extends Node3D

@export var health: int = 100

func _on_take_damage(damage: int) -> void:
  print("Tower took %d damage!" % damage)
