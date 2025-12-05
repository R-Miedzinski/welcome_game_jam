class_name TowerController
extends Node3D

@export var max_health: int = 100
var health: int = 100
var selected_potion: Potion = null

var potion_scene: PackedScene = preload("res://potions/potion.tscn")

@onready var shoot_origin: Marker3D = %ThrowOrigin
@onready var tower_health: Label3D = %HPLabel
@onready var sfx_player: Node = %SFX
@onready var vfx_player: AnimationPlayer = %VFXPlayer

signal shoot_potion(potion: Potion, target_tile: Vector2i, origin: Vector3)
signal tower_destroyed()

func shoot(target_tile: Vector2i) -> void:
  if self.selected_potion == null:
      return

  self.emit_signal("shoot_potion", selected_potion, target_tile, self.shoot_origin.global_position)
  self.selected_potion = null

func update_health() -> void:
  self.tower_health.text = "HP: %d / %d" % [self.health, self.max_health]

func take_damage(amount: int) -> void:
  self.sfx_player.get_node("CarDamage").play()
  self.health -= amount
  if self.health <= 0:
      self.health = 0
  self.update_health()

func _ready() -> void:
  self.process_mode = Node.ProcessMode.PROCESS_MODE_ALWAYS
  self.update_health()

func _on_take_damage(damage: int) -> void:
  print("Tower took %d damage!" % damage)
  self.take_damage(damage)
  if self.health <= 0:
      print("Tower has been destroyed!")
      self.vfx_player.play("explode")
      self.sfx_player.get_node("CarDeath").play()
      self.emit_signal("tower_destroyed")
          

func _on_potion_brewed(potion: Potion) -> void:
  self.selected_potion = potion_scene.instantiate() as Potion
  self.selected_potion.liquid_components = potion.liquid_components.duplicate(true)
  self.selected_potion.solid_components = potion.solid_components.duplicate(true)
  self.selected_potion.effects = potion.effects.duplicate(true)
  self.selected_potion.size = potion.size
  self.selected_potion.duration = potion.duration
