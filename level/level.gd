extends Node3D

@onready var spawn_controller: SpawnersController = %Spawners

signal brewed_potion_received(potion: Potion)
signal update_spawn_counter(time_left: float)

func _on_potion_brewed(potion: Potion) -> void:
    emit_signal("brewed_potion_received", potion)

func _process(delta: float) -> void:
    emit_signal("update_spawn_counter", self.spawn_controller.spawner_timer.time_left)