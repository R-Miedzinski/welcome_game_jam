class_name BaseEnemy
extends Enemy


func attack_player() -> void:
    print("BaseEnemy dealt %d damage!" % self.damage)
    emit_signal("deal_damage", self.damage)

func take_damage(amount: int) -> void:
    animation_player.play("hurt")
    self.health -= amount
    print("BaseEnemy took %d damage, health now %d" % [amount, self.health])

func trigger_effect() -> void:
    print("BaseEnemy effect triggered!")

func _ready() -> void:
    animation_player.animation_finished.connect(
        self._process_animation
    )

func _process(delta: float) -> void:
    if self.health <= 0:
        emit_signal("enemy_defeated", self.position_in_grid, self.idx_in_position)

func _process_animation(anim_name: String) -> void:
    # if anim_name == "hurt":
    #         self.animation_player.play("RESET")
    if anim_name == "death":
            self.queue_free()