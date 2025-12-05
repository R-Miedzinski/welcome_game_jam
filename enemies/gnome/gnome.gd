class_name BaseEnemy
extends Enemy


func take_damage(amount: float) -> void:
    self.health -= amount
    self.hp_label.text = "HP: %.2f / %.2f" % [self.health, self.max_health]
    animation_player.play("hurt")
    if self.health <= 0:
        self._on_death()