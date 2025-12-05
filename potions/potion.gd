class_name Potion
extends Node3D

@export var liquid_components: Array[Component] = []
@export var solid_components: Array[Component] = []
@export var effects: Array[Effect] = []
@export var size: int = 1
@export var duration: int = 1
var repeated_component_counter: Dictionary[String, int] = {}

@onready var sfx_player: Node = $SFX

func splash() -> void:
    self.sfx_player.get_node("GlassShatter").play()
    self.sfx_player.get_node("GlassShatter").connect("finished", self.queue_free)

func brew() -> Potion:
    var new_potion: Potion = Potion.new()
    new_potion.size = self.size
    new_potion.duration = self.duration
    new_potion.effects = []
    new_potion.liquid_components = self.liquid_components.duplicate(true)
    new_potion.solid_components = self.solid_components.duplicate(true)
    new_potion.repeated_component_counter = {}

    for component in new_potion.solid_components:
        component.apply(new_potion)
        for effect in component.effects:
            var effect_copy = effect.duplicate(true)
            effect_copy.id = str(randi())
            new_potion.effects.append(effect_copy)

    for component in new_potion.liquid_components:
        if new_potion.repeated_component_counter.has(component.name):
            new_potion.repeated_component_counter[component.name] += 1
        else:
            new_potion.repeated_component_counter[component.name] = 1
            for effect in component.effects:
                var effect_copy = effect.duplicate(true)
                effect_copy.id = str(randi())
                new_potion.effects.append(effect_copy)

        component.apply(new_potion)

    for effect_type in new_potion.repeated_component_counter.keys():
        var count: int = new_potion.repeated_component_counter[effect_type]
        if count > 0:
            var effect_instance = Preloads.BASE_DAMAGE_EFFECTS[count - 1].duplicate(true)
            effect_instance.id = str(randi())
            new_potion.effects.append(effect_instance)

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
        Constants.EffectTypes.DMG: 0.0,
        Constants.EffectTypes.DOT: 0.0,
        Constants.EffectTypes.DOT_GROUND: 0.0,
        Constants.EffectTypes.SLOW: 1.0,
        Constants.EffectTypes.SLOW_GROUND: 1.0,
    }

    for effect in effects:
        if effect is DamageEffect:
            summary[Constants.EffectTypes.DMG] += effect.value
        elif effect is DotEffect:
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
