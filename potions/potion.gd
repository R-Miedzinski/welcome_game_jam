class_name Potion
extends Node3D

@export var liquid_components: Array[Component] = []
@export var solid_components: Array[Component] = []
@export var effects: Array[Effect] = []
@export var size: int = 1
@export var duration: float = 1.0

# TODO: Needs effects check methods for displays
func brew() -> Potion:
    var new_potion: Potion = Potion.new()
    new_potion.size = self.size
    new_potion.duration = self.duration
    new_potion.effects = []
    new_potion.liquid_components = self.liquid_components.duplicate(true)
    new_potion.solid_components = self.solid_components.duplicate(true)

    for component in liquid_components:
        component.apply(new_potion)

    for component in solid_components:
        component.apply(new_potion)

    return new_potion

func add_component(component: Component) -> void:
    if component.is_liquid:
        liquid_components.append(component)
    else:
        solid_components.append(component)

func has_effect(effect_type: Constants.EffectTypes) -> bool:
    if effects.size() == 0:
        return false

    if effect_type == Constants.EffectTypes.STUN:
        return self._has_stun_effect()
    elif effect_type == Constants.EffectTypes.RESET:
        return self._has_reset_effect()
    elif effect_type == Constants.EffectTypes.MOVE:
        return self._has_move_effect()
    else:
        return false

func get_value_summary() -> Dictionary:
    var summary: Dictionary = {
        Constants.EffectTypes.DOT: 0.0,
        Constants.EffectTypes.DOT_GROUND: 0.0,
        Constants.EffectTypes.SLOW: 1.0,
        Constants.EffectTypes.SLOW_GROUND: 1.0,
    }

    for effect in effects:
        if effect is DotEffect:
            summary[Constants.EffectTypes.DOT] += effect.value
        elif effect is SlowEffect:
            summary[Constants.EffectTypes.SLOW] *= (1 - effect.value)
        elif effect is DotGroundEffect:
            summary[Constants.EffectTypes.DOT_GROUND] += effect.value
        elif effect is SlowGroundEffect:
            summary[Constants.EffectTypes.SLOW_GROUND] *= (1 - effect.value)
    return summary


func _has_reset_effect() -> bool:
    for effect in effects:
        if effect is ResetEffect:
            return true
    return false

func _has_stun_effect() -> bool:
    for effect in effects:
        if effect is StunEffect:
            return true
    return false

func _has_move_effect() -> bool:
    for effect in effects:
        if effect is MoveEffect:
            return true
    return false