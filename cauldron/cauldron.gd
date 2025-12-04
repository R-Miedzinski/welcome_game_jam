extends ColorRect

@export var max_components: int = Constants.CAULDRON_CAPACITY

var potion_scene: PackedScene = preload("res://potions/potion.tscn")
var current_potion: Potion = null

@onready var dot_label: Label = %DOT
@onready var dot_g_label: Label = %DOTGround
@onready var slow_label: Label = %Slow
@onready var slow_g_label: Label = %SlowGround
@onready var range_label: Label = %Range
@onready var time_label: Label = %Time
@onready var potency_label: Label = %Potency
@onready var move_label: CheckBox = %Move
@onready var stun_radio: CheckBox = %Stun
@onready var reset_radio: CheckBox = %Reset


signal potion_brewed(potion: Potion)
signal is_cauldron_full(is_full: bool)

func reset() -> void:
    if self.current_potion != null:
        self.current_potion.queue_free()
        self.current_potion = null

    self.current_potion = potion_scene.instantiate() as Potion
    self.fill_labels(self.current_potion.brew())
    emit_signal("is_cauldron_full", false)

func write_message(text: String, value) -> String:
    return "%s: %s" % [text, str(value)]

# TODO: Update to show actual effect values
func fill_labels(potion: Potion) -> void:
    var summary: Dictionary = potion.get_value_summary()

    self.dot_label.text = self.write_message("DOT +", summary[Constants.EffectTypes.DOT])
    self.dot_g_label.text = self.write_message("DOT Ground +", summary[Constants.EffectTypes.DOT_GROUND])
    self.slow_label.text = self.write_message("Slow *", summary[Constants.EffectTypes.SLOW])
    self.slow_g_label.text = self.write_message("Slow Ground *", summary[Constants.EffectTypes.SLOW_GROUND])
    self.range_label.text = self.write_message("Range +", potion.size)
    self.time_label.text = self.write_message("Time +", potion.duration)
    # self.potency_label.text = self.write_message("Potency", 0)
    self.stun_radio.button_pressed = potion.has_effect(Constants.EffectTypes.STUN)
    self.reset_radio.button_pressed = potion.has_effect(Constants.EffectTypes.RESET)
    self.move_label.button_pressed = potion.has_effect(Constants.EffectTypes.MOVE)

func _ready() -> void:
    self.reset()

func _on_component_added(component: Component) -> void:
    current_potion.add_component(component)
    var is_full: bool = current_potion.liquid_components.size() + current_potion.solid_components.size() >= max_components
    emit_signal("is_cauldron_full", is_full)

    self.fill_labels(self.current_potion.brew())

func _on_brew_button_pressed() -> void:
   if self.current_potion != null and self.current_potion.liquid_components.size() > 0:
        var potion = self.current_potion.brew()
        emit_signal("potion_brewed", potion)
        self.reset()

func _on_reset_button_pressed() -> void:
    self.reset()
