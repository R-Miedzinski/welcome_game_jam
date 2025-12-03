class_name Component
extends Resource

@export var name: String = "Unnamed Component"
@export var texture: Texture2D
@export var is_liquid: bool = true
@export var effects: Array[Effect] = []
@export var duration_modifier: float = 0.0
@export var range_modifier: int = 0
@export var potency_modifier: float = 0.0

func apply(potion: Potion) -> void:
  if !self.is_liquid:
    potion.duration += self.duration_modifier
    potion.size += self.range_modifier
    # TODO: potency modifiers?
    # for effect in potion.effects:
    #   effect.value *= self.potency_modifier
  else:
    for effect in self.effects:
      var effect_copy = effect.duplicate_deep()
      effect_copy.id = str(randi())
      potion.effects.append(effect_copy)
