class_name SlowGroundEffect
extends Effect


func apply(target: Enemy, duration: float = 2 * Constants.EFFECT_TICK_DURATION) -> void:
  target.play_effect_sound(self.name)
  if not target.self_effects.has(self.id):
    target.self_effects[self.id] = [duration, self]
    target.speed_modifier *= (1.0 - self.value)


func lift(target: Enemy) -> void:
    if target.self_effects.has(self.id):
      target.self_effects.erase(self.id)
      target.speed_modifier /= (1.0 - self.value)