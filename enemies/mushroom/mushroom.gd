class_name Mushroom
extends Gnome

func _apply_petrify_vfx() -> void:
    var _material = self.get_node("A_Shroom/Armature_Shroom_Rig/Skeleton3D/shroom_body_001").material_overlay
    if _material:
        _material.set_shader_parameter("is_visible", true)

func _remove_petrify_vfx() -> void:
    var _material = self.get_node("A_Shroom/Armature_Shroom_Rig/Skeleton3D/shroom_body_001").material_overlay
    if _material:
        _material.set_shader_parameter("is_visible", false)
