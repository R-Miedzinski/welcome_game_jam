class_name DotGroundEffect
extends Effect

func apply(target: Enemy, duration: float = 1.0) -> void:
  target.play_effect_sound(self.name)
  target.take_damage(self.value * Constants.EFFECT_TICK_DURATION)

func lift(target: Enemy) -> void:
    pass