@abstract class_name Enemy
extends AnimatableBody3D

@export var max_speed: float = 1
var speed: float = 1
var previous_speed: float = 1
@export var max_health: float = 100
var health: float = 100
@export var damage: int = 10
var is_on_ground: bool = true

@export var dimensions: Vector3 = Vector3(1, 1, 1)
var front_position_in_grid: Vector2i = Vector2i(0, 0)
var back_position_in_grid: Vector2i = Vector2i(0, 0)
var idx_in_position: int = 0

@export var animation_time: float = 5
var self_effects: Dictionary[String, Array] = {} # { effect.id: [duration, effect] }

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hp_label: Label3D = %HPLabel

signal deal_damage(damage: int)
signal enemy_attacked_player(position_in_grid: Vector2i, idx: int)
signal enemy_defeated(position_in_grid: Vector2i, idx: int)

@abstract func take_damage(amount: float) -> void

func attack_player() -> void:
  self.emit_signal("deal_damage", self.damage)
  self.emit_signal("enemy_attacked_player", self.front_position_in_grid, self.idx_in_position)

func force_move(new_position: Vector2i) -> void:
  self.front_position_in_grid = new_position
  self.back_position_in_grid = new_position
  var target_position: Vector3 = self.position
  target_position.x = target_position.x + (new_position.y - self.front_position_in_grid.y) * Constants.TILE_SIZE
  self.position = target_position

func move(delta: float, direction: Constants.MovementDirection) -> void:
  self.move_and_collide(delta * speed * Vector3(direction * Constants.TILE_SIZE, 0, 0))

func pause_movement() -> void:
  self.previous_speed = self.speed
  self.speed = 0

func resume_movement() -> void:
  self.speed = self.previous_speed

func _ready() -> void:
  self.speed = self.max_speed
  self.previous_speed = self.max_speed
  self.health = self.max_health
  hp_label.text = "HP: %d / %d" % [self.health, self.max_health]
  animation_player.animation_finished.connect(
        self._process_animation
    )

func _process(delta: float) -> void:
    if self.health <= 0:
        emit_signal("enemy_defeated", self.front_position_in_grid, self.idx_in_position)

func _process_animation(anim_name: String) -> void:
    if anim_name == "hurt":
            self.animation_player.queue("RESET")
    if anim_name == "death":
            self.queue_free()

func _on_effect_tick() -> void:
  for effect_id in self.self_effects.keys():
    var duration_left: float = self.self_effects[effect_id][0]
    var effect: Effect = self.self_effects[effect_id][1]
    effect.apply(self)
    duration_left -= Constants.EFFECT_TICK_DURATION
    if duration_left <= 0.0:
        effect.lift(self)
        self.self_effects.erase(effect_id)
    else:
        self.self_effects[effect_id][0] = duration_left
