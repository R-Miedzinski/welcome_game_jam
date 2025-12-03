class_name DamageEffect
extends Effect

func apply(target: Enemy, duration: float = 1.0) -> void:
  target.take_damage(value * Constants.EFFECT_TICK_DURATION)

func lift(target: Enemy) -> void:
    pass
