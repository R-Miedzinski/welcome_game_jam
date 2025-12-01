extends Node

@onready var level_scene: Node3D = %Level

func _process(delta: float) -> void:
  if Input.is_action_just_pressed("ui_select"):
    level_scene.get_node("%Spawners").spawn_enemy_at_random()
