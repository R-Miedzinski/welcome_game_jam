extends Button

var idx_in_conveyor: int = -1
var is_hovered: bool = false

signal component_clicked(component: int)

func set_overlay_color(color: Color) -> void:
    var _material = self.material as ShaderMaterial
    if _material:
        _material.set_shader_parameter("overlay_color", color)

func _on_mouse_entered() -> void:
    self.set_overlay_color(Color(1, 1, 1, 0.7))
    self.is_hovered = true

func _on_mouse_exited() -> void:
    self.set_overlay_color(Color(1, 1, 1, 0))
    self.is_hovered = false

func _process(delta: float) -> void:
    if Input.is_action_just_pressed("component_interact") and self.is_hovered:
        emit_signal("component_clicked", self.idx_in_conveyor)
