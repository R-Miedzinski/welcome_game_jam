class_name DamageEffect
extends Effect

func apply(target: Enemy, duration: float = 0.0) -> void:
  if not target.self_effects.has(self.id):
    target.self_effects[self.id] = [duration + Constants.EFFECT_TICK_DURATION, self]
    target.take_damage(self.value)

func lift(target: Enemy) -> void:
  if target.self_effects.has(self.id):
    target.self_effects.erase(self.id)
