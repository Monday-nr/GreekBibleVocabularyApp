extends PanelContainer

const DEFAULT_DISPLAY_TIME: float = 6.0 # seconds
const NO_AUTO_REMOVE: float = 9999999.0 # seconds

@onready var _message_label: Label = $MarginContainer/MessageLabel

var _id: int = 0

func _init() -> void:
	Global.message = self

func _input(event: InputEvent) -> void:
	if not event is InputEventMouseMotion:
		clear()

func display(message: String, remove_at_input: bool = true, for_seconds: float = NO_AUTO_REMOVE) -> void:
	_id += 1
	Controls.enable(false)
	_message_label.text = message
	set_visible(true)
	if for_seconds != NO_AUTO_REMOVE:
		create_tween().tween_callback(__message_timeout.bind(_id)).set_delay(for_seconds)
	set_process_input(remove_at_input)

func __message_timeout(id_: int) -> void:
	if _id == id_:
		clear()

func clear() -> void:
	_id = 0
	set_visible(false)
	set_process_input(false)
	Controls.enable(true)
