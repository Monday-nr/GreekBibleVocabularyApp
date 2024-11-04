extends VBoxContainer

@onready var color_picker: ColorPicker = $ColorPicker2
@onready var _close_button: Button = $ColorPickerCloseButton

var _connected_callable: Callable

func _ready() -> void:
	_close_button.pressed.connect(close)

func display(callable: Callable, color_: Color = color_picker.color) -> void:
	if _connected_callable != null and _connected_callable.is_valid() and color_picker.color_changed.is_connected(_connected_callable):
		color_picker.color_changed.disconnect(_connected_callable)
	color_picker.color_changed.connect(callable)
	_connected_callable = callable
	color_picker.color = color_
	set_visible(true)
	set_process_unhandled_key_input(true)

func close() -> void:
	if _connected_callable != null and _connected_callable.is_valid() and color_picker.color_changed.is_connected(_connected_callable):
		color_picker.color_changed.disconnect(_connected_callable)
	set_visible(false)
	set_process_unhandled_key_input(false)
