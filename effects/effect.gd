@abstract class_name Effect
extends Resource

# Based on this, effects can be attached to enemies or ground, assign in Resource creation
enum TargetLocation {
  SELF,
  GROUND
}

@export var value: float = 1.0
@export var target_location: TargetLocation = TargetLocation.GROUND
var id: String = ""

@abstract func apply(target: Enemy, duration: float = 0.0) -> void
@abstract func lift(target: Enemy) -> void