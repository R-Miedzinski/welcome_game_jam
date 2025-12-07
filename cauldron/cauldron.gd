extends ColorRect

@export var max_components: int = Constants.CAULDRON_CAPACITY

var potion_scene: PackedScene = preload("res://potions/potion.tscn")
var current_potion: Potion = null

@onready var dmg_label: Label = %DMG
@onready var dot_label: Label = %DOT
@onready var dot_g_label: Label = %DOTGround
@onready var slow_label: Label = %Slow
@onready var slow_g_label: Label = %SlowGround
@onready var range_label: Label = %Range
@onready var time_label: Label = %Time
@onready var components_count_label: Label = %ComponentsCount
@onready var move_label: CheckBox = %Move
@onready var stun_radio: CheckBox = %Stun
@onready var reset_radio: CheckBox = %Reset

@onready var sfx: Node = %SFX
@onready var brew_button: Button = %BrewPotion

signal potion_brewed(potion: Potion)
signal is_cauldron_full(is_full: bool)

func reset() -> void:
    if self.current_potion != null:
        self.current_potion.queue_free()
        self.current_potion = null

    self.current_potion = potion_scene.instantiate() as Potion
    self.fill_labels(self.current_potion.brew())
    self.brew_button.disabled = true
    emit_signal("is_cauldron_full", false)

func write_message(value) -> String:
    return "%s" % value

func fill_labels(potion: Potion) -> void:
    var summary: Dictionary = potion.get_value_summary()

    self.dmg_label.text = self.write_message(summary[Constants.EffectTypes.DMG])
    self.dot_label.text = self.write_message(summary[Constants.EffectTypes.DOT])
    self.dot_g_label.text = self.write_message(summary[Constants.EffectTypes.DOT_GROUND])
    self.slow_label.text = self.write_message(summary[Constants.EffectTypes.SLOW])
    self.slow_g_label.text = self.write_message(summary[Constants.EffectTypes.SLOW_GROUND])
    self.range_label.text = self.write_message(potion.size)
    self.time_label.text = self.write_message(potion.duration)
    self.components_count_label.text = "%d / %d" % [potion.liquid_components.size() + potion.solid_components.size(), self.max_components]
    self.stun_radio.button_pressed = potion.has_effect(Constants.EffectTypes.STUN)
    self.reset_radio.button_pressed = potion.has_effect(Constants.EffectTypes.RESET)
    self.move_label.button_pressed = potion.has_effect(Constants.EffectTypes.MOVE)

func _ready() -> void:
    self.reset()

func _on_component_added(component: Component) -> void:
    if component.is_liquid:
        self.sfx.get_node("Nalewanie").play()
    else:
        self.sfx.get_node("Proszek").play()

    current_potion.add_component(component)
    var is_full: bool = current_potion.liquid_components.size() + current_potion.solid_components.size() >= max_components
    emit_signal("is_cauldron_full", is_full)

    if current_potion.liquid_components.size() > 0:
        self.brew_button.disabled = false
    self.fill_labels(self.current_potion.brew())

func _on_brew_button_pressed() -> void:
   if self.current_potion != null and self.current_potion.liquid_components.size() > 0:
        self.sfx.get_node("Mieszanie").play()
        var potion = self.current_potion.brew()
        emit_signal("potion_brewed", potion)
        self.reset()

func _on_reset_button_pressed() -> void:
    self.sfx.get_node("Wylewanie").play()
    self.reset()
