class_name Potion
extends Node3D

@export var liquid_components: Array = []
@export var solid_components: Array = []
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