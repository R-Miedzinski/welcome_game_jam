class_name StunEffect
extends Effect

func apply(target: Enemy, duration: float = 1.0) -> void:
  if not target.self_effects.has(self.id):
    target.play_effect_sound(self.name)
    target.self_effects[self.id] = [duration + Constants.EFFECT_TICK_DURATION, self]
    target.pause_movement()

func lift(target: Enemy) -> void:
    if target.self_effects.has(self.id):
      target.self_effects.erase(self.id)
      target.resume_movement()