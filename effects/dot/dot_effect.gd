class_name DotEffect
extends Effect

func apply(target: Enemy, duration: float = 1.0) -> void:
  target.play_effect_sound(self.name)
  if not target.self_effects.has(self.id):
    target.self_effects[self.id] = [duration, self]
    target.take_damage(self.value * Constants.EFFECT_TICK_DURATION)
  else:
    target.take_damage(self.value * Constants.EFFECT_TICK_DURATION)

func lift(target: Enemy) -> void:
    if target.self_effects.has(self.id):
      target.self_effects.erase(self.id)
