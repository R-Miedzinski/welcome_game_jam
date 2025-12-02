extends Potion

func _ready() -> void:
    var damage_effect: DamageEffect = DamageEffect.new()
    damage_effect.value = 25.0
    effects.append(damage_effect)

    var debug_effect: DebugEffect = DebugEffect.new()
    debug_effect.debug_message = "Instant Damage Potion Used"
    effects.append(debug_effect)