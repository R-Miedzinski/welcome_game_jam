@abstract class_name Effect
extends Node

@export var duration: float = 1.0
@export var value: float = 1.0

@abstract func apply_effect(target: Enemy) -> void