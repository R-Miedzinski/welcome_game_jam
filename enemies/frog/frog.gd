class_name Frog
extends Enemy

@export var jump_height: float = 2.0
@export var jump_cooldown: float = 2.0
@export var skip_tiles: int = 1

@onready var jump_timer: Timer = %JumpTimer
var is_moving: bool = false
var just_spawned: bool = true

@export var jump_anim_offset: float = 1.5

func take_damage(amount: float) -> void:
    self.health -= amount
    self.hp_label.text = "HP: %.2f / %.2f" % [self.health, self.max_health]
    animation_player.play("hurt")
    if self.health <= 0:
        self._on_death()

func move(delta: float, direction: Constants.MovementDirection) -> void:
    if self.animation_player.current_animation == "attack" or self.animation_player.current_animation == "death" or self.is_paused:
        return

    if self.jump_timer.time_left <= self.jump_anim_offset and not self.just_spawned:
        self.animation_player.play("walk")
        self.animation_player.advance(0)
    elif self.just_spawned:
        self.animation_player.play("jump_land")
        self.animation_player.advance(0)

    if self.is_moving:
        return
        
    self.is_moving = true
    self.is_on_ground = false

    var jump_distance: float = (1 + self.skip_tiles) * Constants.TILE_SIZE

    var tween = self.get_tree().create_tween()
    tween.set_parallel(true)
    tween.tween_property(self, "position:x", self.position.x + direction * jump_distance, animation_time)
    tween.tween_property(self, "position:y", self.position.y + jump_height, animation_time / 2)
    tween.tween_property(self, "position:y", self.position.y, animation_time / 2).set_delay(animation_time / 2)

    tween.finished.connect(
        func() -> void:
            self.is_on_ground = true
            self.jump_timer.start(self.jump_cooldown)
    )

    self.sfx_player.get_node("Intro").get_child(self.intro_sound_id).play()

func pause_movement() -> void:
    super ()
    if not self.jump_timer.is_stopped():
        self.jump_timer.stop()

func resume_movement() -> void:
    if self.jump_timer.is_stopped() and self.is_paused:
        self.jump_timer.start(self.jump_cooldown)
    super ()

func _process_animation(anim_name: String) -> void:
    super (anim_name)
    if anim_name == "walk":
        self.animation_player.play("idle")
    elif anim_name == "jump_land" and self.just_spawned:
        self.just_spawned = false
        self.animation_player.play("idle")

func _ready() -> void:
    super ()
    self.jump_timer.wait_time = self.jump_cooldown
    self.jump_timer.one_shot = true

func _on_jump_cooldown_reset() -> void:
    self.is_moving = false

func _apply_petrify_vfx() -> void:
    var _material = self.get_node("A_FrogKnoight/RIG_FROG/Skeleton3D/frougue_retopo_001").material_overlay
    if _material:
        _material.set_shader_parameter("is_visible", true)

func _remove_petrify_vfx() -> void:
    var _material = self.get_node("A_FrogKnoight/RIG_FROG/Skeleton3D/frougue_retopo_001").material_overlay
    if _material:
        _material.set_shader_parameter("is_visible", false)
