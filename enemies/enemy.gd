@abstract class_name Enemy
extends AnimatableBody3D

@export var speed: int = 1
@export var health: int = 100
@export var damage: int = 10

@export var position_in_grid: Vector2i = Vector2i(0, 0)
@export var dimensions: Vector3 = Vector3(1, 1, 1)

@export var animation_time: float = 5
@export var is_moving: bool = false

signal deal_damage(damage: int)
@abstract func attack_player() -> void
@abstract func take_damage(amount: int) -> void
@abstract func trigger_effect() -> void

func move(tile_width: float) -> void:
  if !self.is_moving:
    self.is_moving = true
    var target_x = position.x + speed * tile_width

    var tween = get_tree().create_tween()
    tween.set_parallel()
    tween.tween_property(self, "position:x", target_x, animation_time)

    tween.finished.connect(
      _move_completed
    )

func _move_completed() -> void:
  self.is_moving = false
  self.position_in_grid.y += speed
  print("Enemy moved to grid position: %s" % position_in_grid)
