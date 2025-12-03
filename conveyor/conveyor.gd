class_name Conveyor
extends ColorRect

@export var time_per_component: float = 3.0
@export var capacity: int = 10
var is_cauldron_full: bool = false

var components: Array[Component] = []
var available_components_liquid: Array[Component] = [
  preload("res://components/fire/fire_component_liquid.tres"),
]
var available_components_solid: Array[Component] = [
  preload("res://components/fire/fire_component_solid.tres"),
]
var component_scene: PackedScene = preload("res://components/component.tscn")

var random_number_generator: RandomNumberGenerator = RandomNumberGenerator.new()

@onready var conveyor_components: FlowContainer = %ConveyorComponents
@onready var component_timer: Timer = %ComponentTimer
@onready var till_component: Label = $Label


signal component_added(component: Component)

func remove_from_conveyor(idx: int) -> Component:
  if idx < 0 or idx >= self.components.size():
    return

  var removed_component = self.components.pop_at(idx).duplicate(true)
  self.conveyor_components.get_child(idx).queue_free()
  for i in range(idx, self.conveyor_components.get_child_count()):
    var component_node: Button = self.conveyor_components.get_child(i)
    component_node.idx_in_conveyor = i - 1
    component_node.text = str(i)

  if self.components.size() < self.capacity and self.component_timer.is_stopped():
    self._on_spawn_component_timeout()
    self.component_timer.start()
  return removed_component

func _process(delta: float) -> void:
  self.till_component.text = "Next Component in: %.1f s" % (self.component_timer.time_left)

func _ready() -> void:
  self.component_timer.wait_time = time_per_component
  self.component_timer.start()

func _on_spawn_component_timeout() -> void:
  if self.components.size() >= self.capacity:
    self.component_timer.stop()
    return

  var draw_solid: bool = self.random_number_generator.randi() % 3 == 0
  var component_idx: int = -1
  var component: Component = null

  if draw_solid and self.available_components_solid.size() > 0:
    component_idx = self.random_number_generator.randi() % self.available_components_solid.size()
    component = self.available_components_solid[component_idx]
  elif self.available_components_liquid.size() > 0:
    component_idx = self.random_number_generator.randi() % self.available_components_liquid.size()
    component = self.available_components_liquid[component_idx]

  if component != null:
    self.components.append(component)
    var component_instance: Button = self.component_scene.instantiate()
    component_instance.icon = component.texture
    component_instance.idx_in_conveyor = self.components.size() - 1
    component_instance.get_node("Label").text = component.name + " L" if component.is_liquid else component.name + " S"
    component_instance.text = str(self.components.size())
    component_instance.connect(
      "component_clicked",
      self._on_component_clicked
    )

    self.conveyor_components.add_child(component_instance)

func _on_component_clicked(component_idx: int) -> void:
  if self.is_cauldron_full:
    return
  var removed_component = remove_from_conveyor(component_idx)
  emit_signal("component_added", removed_component)

func _on_cauldron_is_full(is_full: bool) -> void:
  self.is_cauldron_full = is_full
