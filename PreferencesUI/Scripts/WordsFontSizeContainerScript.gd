extends LineEdit

var _font_size: int = 30


func _ready() -> void:
	Global.register_node_with_text(self)
	SignalHandler.connect_signal(SignalHandler.Sl.LOAD_CONFIG, _sl_load_config)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_action_pressed("enter"):
			if text.is_valid_int():
				release_focus()
				_font_size_changed(int(text))
			else:
				text = str(_font_size)
		elif event.is_action_pressed("back"):
			release_focus()
			text = str(_font_size)
		else: return
		get_viewport().set_input_as_handled()

func _font_size_changed(new_val: int) -> void:
	_font_size = new_val
	Global.words_label_settings.font_size = new_val

	var data: Array[Array] = [
		["words_font_size", "size", _font_size],
	]
	SaveLoad.save(data)

func _sl_load_config(config_file: ConfigFile) -> void:
	if config_file.has_section("words_font_size"):
		_font_size = config_file.get_value("words_font_size", "size")
	Global.words_label_settings.font_size = _font_size
	text = str(_font_size)
