extends PanelContainer

var _mouse_pos := Vector2i.ZERO

func _ready() -> void:
	Global.settings_container = self
	Controls.register_controls(_enable_controls)
	SignalHandler.connect_signal(SignalHandler.Sl.ADVANCED, _hide)
	%Preferences.visibility_changed.connect(_sl_preferences_visibility_changed)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and not is_visible():
		if 2500 < event.position.distance_squared_to(_mouse_pos):
			_mouse_pos = event.position
			set_visible(true)

func _enable_controls(enable: bool) -> void:
	set_process_input(enable)

func _hide() -> void:
	if is_visible():
		set_visible(false)

func _sl_preferences_visibility_changed() -> void:
	var set_to_visible: bool = not %Preferences.is_visible()
	set_visible(set_to_visible)
	set_process_input(set_to_visible)
