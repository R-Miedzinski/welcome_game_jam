class_name MoveEffect
extends Effect

@export var direction: Constants.MovementDirection = Constants.MovementDirection.LEFT
@export var displacement_time: float = 0.2

func apply(target: Enemy, duration: float = Constants.EFFECT_TICK_DURATION) -> void:
  if !target.is_on_ground:
    return
    
  var displacement_vector = Vector2i.ZERO
  if self.direction == Constants.MovementDirection.LEFT:
    displacement_vector = target.front_position_in_grid + Vector2i(0, int(self.value))
  elif self.direction == Constants.MovementDirection.RIGHT:
    displacement_vector = target.front_position_in_grid - Vector2i(0, int(self.value))
  elif self.direction == Constants.MovementDirection.UP:
    displacement_vector = target.front_position_in_grid + Vector2i(int(self.value), 0)
  elif self.direction == Constants.MovementDirection.DOWN:
    displacement_vector = target.front_position_in_grid - Vector2i(int(self.value), 0)

  target.force_move(displacement_vector, self.displacement_time)

func lift(target: Enemy) -> void:
    pass