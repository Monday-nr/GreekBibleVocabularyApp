class_name Controls
extends RefCounted

static var _control_setters: Array[Callable] = []

static func register_controls(setter: Callable, disable_on_registering: bool = true) -> void:
	setter.call(not disable_on_registering)
	_control_setters.append(setter)

static func enable(enable_: bool) -> void:
	for setter: Callable in _control_setters:
		setter.call(enable_)
