@abstract class_name Enemy
extends AnimatableBody3D

@export var max_speed: float = 1
var speed: float = 1
var previous_speed: float = 1
var speed_modifier: float = 1.0

@export var max_health: float = 100
var health: float = 100
@export var damage: int = 10
var is_on_ground: bool = true
var is_paused: bool = false
var stop_processing: bool = false
var death_processed: bool = false

@export var dimensions: Vector3 = Vector3(1, 1, 1)
var front_position_in_grid: Vector2i = Vector2i(0, 0)
var back_position_in_grid: Vector2i = Vector2i(0, 0)
var idx_in_position: int = 0

@export var animation_time: float = 5
var self_effects: Dictionary[String, Array] = {} # { effect.id: [duration, effect] }

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hp_label: Label3D = %HPLabel

@onready var sfx_player: Node = %SFX
var registered_effects_sfx: Dictionary[String, AudioStreamPlayer] = {}
var death_sound_id: int = 0
var attack_sound_id: int = 0
var intro_sound_id: int = 0

signal deal_damage(damage: int)
signal enemy_attacked_player(position_in_grid: Vector2i, idx: int)
signal enemy_defeated(position_in_grid: Vector2i, idx: int)

@abstract func take_damage(amount: float) -> void

func attack_player() -> void:
  self.emit_signal("deal_damage", self.damage)
  self.emit_signal("enemy_attacked_player", self.front_position_in_grid, self.idx_in_position)

  self.animation_player.play("attack")
  if self.attack_sound_id != -1:
    var attack_sound_player = self.sfx_player.get_node("Attack").get_child(self.attack_sound_id)
    attack_sound_player.play()
    attack_sound_player.finished.connect(
        func() -> void:
            self.death_processed = true
    )

func force_move(new_position: Vector2i, move_time: float) -> void:
  self.pause_movement()
  self.is_on_ground = false

  var tween: Tween = create_tween()
  var normalized_new_position: Vector2i = self._normalize_target_position_to_grid(new_position)
  var target_pos_x = self.position.x + (normalized_new_position.y - self.front_position_in_grid.y) * Constants.TILE_SIZE
  
  tween.tween_property(self, "position:x", target_pos_x, move_time)
  tween.finished.connect(func() -> void:
    self.is_on_ground = true
    self.resume_movement()
  )

func move(delta: float, direction: Constants.MovementDirection) -> void:
  if !self.visible and self.death_processed:
    self.queue_free()
    return

  if self.animation_player.current_animation == "attack" or self.animation_player.current_animation == "death" or self.is_paused:
    return
  self.move_and_collide(delta * self.speed_modifier * self.speed * Vector3(direction * Constants.TILE_SIZE, 0, 0))

func pause_movement() -> void:
  if !self.is_paused:
    self.previous_speed = self.speed
    self.speed = 0
    self.is_paused = true
    self.animation_player.pause()

func resume_movement() -> void:
  if self.is_paused:
    self.speed = self.previous_speed
    self.is_paused = false
    self.animation_player.play("walk")

func play_effect_sound(effect_name: String) -> void:
  if Preloads.EFFECT_SFX.has(effect_name):
    var sfx_sound: AudioStream = Preloads.EFFECT_SFX[effect_name]
    var sfx_instance: AudioStreamPlayer = AudioStreamPlayer.new()
    sfx_instance.stream = sfx_sound
    sfx_instance.bus = Constants.SFX_BUS_NAME

    if not self.registered_effects_sfx.has(effect_name):
      self.registered_effects_sfx[effect_name] = sfx_instance
      self.get_tree().get_current_scene().add_child(sfx_instance)
      sfx_instance.play()
      sfx_instance.finished.connect(
          func() -> void:
              sfx_instance.queue_free()
      )

func _ready() -> void:
  self.speed = self.max_speed
  self.previous_speed = self.max_speed
  self.health = self.max_health
  hp_label.text = "HP: %d / %d" % [self.health, self.max_health]

  self.animation_player.animation_finished.connect(
        self._process_animation
    )

func _on_death() -> void:
    self.stop_processing = true
    self.pause_movement()
    emit_signal("enemy_defeated", self.front_position_in_grid, self.idx_in_position)

    self.animation_player.play("death")
    self.animation_player.advance(0)

    if self.death_sound_id != -1:
        var death_sound_player = self.sfx_player.get_node("Death").get_child(self.death_sound_id)
        death_sound_player.play()
        death_sound_player.finished.connect(
            func() -> void:
                self.death_processed = true
        )

func _process_animation(anim_name: String) -> void:
    if anim_name == "hurt":
      self.animation_player.queue("walk")
    if anim_name == "death":
      self.visible = false
    if anim_name == "attack":
      self.visible = false

func _on_effect_tick() -> void:
  for effect_id in self.self_effects.keys():
    if self.stop_processing:
        break
    var duration_left: float = self.self_effects[effect_id][0]
    var effect: Effect = self.self_effects[effect_id][1]
    effect.apply(self)
    duration_left -= Constants.EFFECT_TICK_DURATION
    if duration_left <= 0.0:
        effect.lift(self)
        self.self_effects.erase(effect_id)
    else:
        self.self_effects[effect_id][0] = duration_left
        
func _normalize_target_position_to_grid(target_position: Vector2i) -> Vector2i:
  var normalized_x: int = clamp(target_position.x, 0, Constants.GRID_SIZE.x - 1)
  var normalized_y: int = clamp(target_position.y, 0, Constants.GRID_SIZE.y)
  return Vector2i(normalized_x, normalized_y)
