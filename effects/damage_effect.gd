class_name DamageEffect
extends Effect

func apply(target: Enemy) -> void:
  print("Applying DamageEffect to %s for %d damage" % [target.name, int(value)])
  target.take_damage(int(value))

func lift(target: Enemy) -> void:
    pass