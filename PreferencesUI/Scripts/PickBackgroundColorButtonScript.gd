extends Button

const ALTERNATE_BACKGROUND_LIGHTEN_AMOUNT: float = 0.025

@onready var color_picker: VBoxContainer = %ColorPicker

var _background_color := Color(0.1, 0.1, 0.1)

func _init() -> void:
	Global.register_node_with_text(self)

func _ready() -> void:
	SignalHandler.connect_signal(SignalHandler.Sl.LOAD_CONFIG, _sl_load_config)
	pressed.connect(_sl_pressed)

func _sl_pressed() -> void:
	color_picker.display(_sl_color_changed, _background_color)

func _sl_color_changed(color_: Color, save: bool = true) -> void:
	_background_color = color_

	for background: ColorRect in Global.get_backgrounds():
		background.color = color_

	var alt_color: Color = color_.lightened(ALTERNATE_BACKGROUND_LIGHTEN_AMOUNT)
	for alt_background: ColorRect in Global.get_alternate_backgrounds():
		alt_background.color = alt_color

	if save:
		var data: Array[Array] = [
			["background_color", "r", _background_color.r],
			["background_color", "g", _background_color.g],
			["background_color", "b", _background_color.b],
		]
		SaveLoad.save(data)

func _sl_load_config(config_file: ConfigFile) -> void:
	if config_file.has_section("background_color"):
		_background_color = Color(
			config_file.get_value("background_color", "r"),
			config_file.get_value("background_color", "g"),
			config_file.get_value("background_color", "b")
			)
	_sl_color_changed(_background_color, false)
