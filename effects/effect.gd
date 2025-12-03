@abstract class_name Effect
extends Resource

@export var value: float = 1.0
var duration: float = 0.0
  
@abstract func apply(target: Enemy) -> void
@abstract func lift(target: Enemy) -> void