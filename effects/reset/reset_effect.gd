class_name ResetEffect
extends Effect

func apply(target: Enemy, duration: float = 1.0) -> void:
  print("Applying ResetEffect to ", target)
  if not target.is_on_ground:
    return

  var target_position: Vector2i = Vector2i(target.front_position_in_grid.x, Constants.GRID_SIZE.y)
  target.force_move(target_position, Constants.EFFECT_TICK_DURATION)

func lift(target: Enemy) -> void:
  if target.health <= 0:
      target._on_death()
