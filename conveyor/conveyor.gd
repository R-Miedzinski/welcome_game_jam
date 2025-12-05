class_name Conveyor
extends ColorRect

@export var time_per_component: float = Constants.COMPONENT_SPAWN_INTERVAL
@export var capacity: int = Constants.CONVEYOR_CAPACITY
var is_cauldron_full: bool = false

var components: Array[Component] = []
var component_scene: PackedScene = preload("res://components/component.tscn")

var random_number_generator: RandomNumberGenerator = RandomNumberGenerator.new()

@onready var conveyor_components: GridContainer = %ConveyorComponents
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
  # for _id in range(2):
  if self.components.size() >= self.capacity:
    self.component_timer.stop()
    return

  var draw_solid: bool = self.random_number_generator.randi() % Constants.SOLID_FACTOR == 0
  var component_idx: int = -1
  var component: Component = null

  if draw_solid and Preloads.AVAILABLE_SOLID_COMPONENTS.size() > 0:
    component_idx = self.random_number_generator.randi() % Preloads.AVAILABLE_SOLID_COMPONENTS.size()
    component = Preloads.AVAILABLE_SOLID_COMPONENTS[component_idx]
  elif Preloads.AVAILABLE_LIQUID_COMPONENTS.size() > 0:
    component_idx = self.random_number_generator.randi() % Preloads.AVAILABLE_LIQUID_COMPONENTS.size()
    component = Preloads.AVAILABLE_LIQUID_COMPONENTS[component_idx]

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
