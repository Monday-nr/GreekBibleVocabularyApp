extends Button

@onready var color_picker: VBoxContainer = %ColorPicker

var _text_color: Color = Global.words_label_settings.font_color

func _init() -> void:
	Global.register_node_with_text(self)

func _ready() -> void:
	SignalHandler.connect_signal(SignalHandler.Sl.LOAD_CONFIG, _sl_load_config)
	pressed.connect(_sl_pressed)
	call_deferred("_sl_color_changed", Global.words_label_settings.font_color, false)

func _sl_pressed() -> void:
	color_picker.display(_sl_color_changed, _text_color)

func _sl_color_changed(color_: Color, save_:bool = true) -> void:
	_text_color = color_
	Global.words_label_settings.font_color = color_
	Global.verse_label_settings.font_color = color_
	Global.menu_label_settings.font_color = color_

	for node: Node in Global.get_nodes_with_text():
		node.add_theme_color_override("font_color", color_)

	if save_:
		var data: Array[Array] = [
			["font_color", "r", Global.words_label_settings.font_color.r],
			["font_color", "g", Global.words_label_settings.font_color.g],
			["font_color", "b", Global.words_label_settings.font_color.b],
		]
		SaveLoad.save(data)

func _sl_load_config(config_file: ConfigFile) -> void:
	if config_file.has_section("font_color"):
		_sl_color_changed(
			Color(
				config_file.get_value("font_color", "r"),
				config_file.get_value("font_color", "g"),
				config_file.get_value("font_color", "b")),
				false
			)
