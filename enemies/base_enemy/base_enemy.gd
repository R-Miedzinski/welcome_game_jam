class_name BaseEnemy
extends Enemy

func attack_player() -> void:
    print("BaseEnemy dealt %d damage!" % damage)
    emit_signal("deal_damage", damage)

func take_damage(amount: int) -> void:
    health -= amount

func trigger_effect() -> void:
    print("BaseEnemy effect triggered!")
