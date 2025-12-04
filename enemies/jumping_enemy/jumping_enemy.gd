class_name JumpingEnemy
extends Enemy

@export var jump_height: float = 2.0
@export var jump_cooldown: float = 2.0
@export var skip_tiles: int = 1

@onready var jump_timer: Timer = %JumpTimer
var is_moving: bool = false

func take_damage(amount: float) -> void:
    self.health -= amount
    self.hp_label.text = "HP: %.2f / %.2f" % [self.health, self.max_health]
    animation_player.play("hurt")
    if self.health <= 0:
        self._on_death()


func move(delta: float, direction: Constants.MovementDirection) -> void:
    if self.is_moving or self.is_paused:
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
            # TODO: handle speed -> 0 case
            self.jump_timer.start(self.jump_cooldown / self.speed_modifier)
    )

func pause_movement() -> void:
    super ()
    if !self.jump_timer.is_stopped():
        self.jump_timer.stop()

func resume_movement() -> void:
    super ()
    if self.jump_timer.is_stopped():
        self.jump_timer.start(self.jump_cooldown / self.speed_modifier)

func _ready() -> void:
    super ()
    self.jump_timer.wait_time = self.jump_cooldown
    self.jump_timer.one_shot = true

func _on_jump_cooldown_reset() -> void:
    self.is_moving = false