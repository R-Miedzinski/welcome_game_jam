class_name DebugEffect
extends Effect

var debug_message: String = "Debug Effect Applied"

func apply(target: Enemy) -> void:
    print("Applying DebugEffect to %s with message %s" % [target.name, debug_message])

func lift(target: Enemy) -> void:
    print("Lifting DebugEffect from %s" % target.name)