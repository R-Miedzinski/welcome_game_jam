class_name Component
extends Resource

@export var name: String = "Unnamed Component"
@export var texture: Texture2D
@export var is_liquid: bool = true
@export var effects: Array[Effect] = []
@export var duration_modifier: int = 0
@export var range_modifier: int = 0

func apply(potion: Potion) -> void:
  potion.duration += self.duration_modifier
  potion.size += self.range_modifier
