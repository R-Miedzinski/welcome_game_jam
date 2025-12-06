class_name DotGroundEffect
extends Effect

func apply(target: Enemy, duration: float = Constants.EFFECT_TICK_DURATION) -> void:
  target.play_effect_sound(self.name)
  # if not target.self_effects.has(self.id):
  #   target.self_effects[self.id] = [duration, self]
  # else:
  target.take_damage(self.value * Constants.EFFECT_TICK_DURATION)

func lift(target: Enemy) -> void:
    pass
