class_name TowerController
extends Node3D

@export var max_health: int = 100
var health: int = 100
var selected_potion: Potion = null
# var fire_component: Component = preload("res://components/fire/fire_component_liquid.tres")
var potion_scene: PackedScene = preload("res://potions/potion.tscn")

@onready var shoot_origin: Marker3D = %ThrowOrigin
@onready var tower_health: Label3D = %HPLabel

signal shoot_potion(potion: Potion, target_tile: Vector2i, origin: Vector3)

func shoot(target_tile: Vector2i) -> void:
  if self.selected_potion == null:
      return

  # var potion: Potion = self.selected_potion.instantiate()
  # potion.add_component(fire_component)
  # potion.brew()

  # print("Brewed potion with effects:")
  # for effect in potion.effects:
  #     print("- Effect: %s, Value: %f" % [effect.get_class(), effect.value])
  # print("Potion size: %d, duration: %f" % [potion.size, potion.duration])

  emit_signal("shoot_potion", selected_potion, target_tile, self.shoot_origin.global_position)
  self.selected_potion = null

func update_health(new_health: int) -> void:
  self.health = new_health
  if self.health <= 0:
      self.health = 0
  self.tower_health.text = "HP: %d / %d" % [self.health, self.max_health]

func _ready() -> void:
  self.update_health(self.max_health)
#   self.selected_potion = preload("res://potions/potion.tscn")

func _on_take_damage(damage: int) -> void:
  print("Tower took %d damage!" % damage)
  update_health(self.health - damage)

func _on_potion_brewed(potion: Potion) -> void:
  self.selected_potion = potion_scene.instantiate() as Potion
  self.selected_potion.liquid_components = potion.liquid_components.duplicate(true)
  self.selected_potion.solid_components = potion.solid_components.duplicate(true)
  self.selected_potion.effects = potion.effects.duplicate(true)
  self.selected_potion.size = potion.size
  self.selected_potion.duration = potion.duration
