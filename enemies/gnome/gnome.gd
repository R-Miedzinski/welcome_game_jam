class_name Gnome
extends Enemy

func take_damage(amount: float) -> void:
    self.health -= amount
    self.hp_label.text = "HP: %.2f / %.2f" % [self.health, self.max_health]
    if self.health <= 0:
        self._on_death()

func _apply_petrify_vfx() -> void:
    var _material = self.get_node("A_Gnome_Torch/Armature_Gnome_Rig/Skeleton3D/Gnome").material_overlay
    if _material:
        _material.set_shader_parameter("is_visible", true)

func _remove_petrify_vfx() -> void:
    var _material = self.get_node("A_Gnome_Torch/Armature_Gnome_Rig/Skeleton3D/Gnome").material_overlay
    if _material:
        _material.set_shader_parameter("is_visible", false)
