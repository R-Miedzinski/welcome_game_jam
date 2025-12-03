extends Node3D

signal brewed_potion_received(potion: Potion)

func _on_potion_brewed(potion: Potion) -> void:
    emit_signal("brewed_potion_received", potion)