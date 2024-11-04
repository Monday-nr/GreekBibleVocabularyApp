extends HSlider

@onready var gap_between_word_labels: Control = $"../../../Words/Gap"
const GAP_SIZE_MULTIPLIER: float = 0.7

func _ready() -> void:
	SignalHandler.connect_signal(SignalHandler.Sl.LOAD_CONFIG, _sl_load_config)

func _sl_value_changed(new_val: float) -> void:
	Global.words_label_settings.font_size = new_val
	gap_between_word_labels.custom_minimum_size.y = new_val * GAP_SIZE_MULTIPLIER

	var data: Array[Array] = [
		["font_size", "size", Global.words_label_settings.font_size],
	]
	SaveLoad.save(data)

func _sl_load_config(config_file: ConfigFile) -> void:
	if config_file.has_section("font_size"):
		Global.words_label_settings.font_size = config_file.get_value("font_size", "size")
	value = Global.words_label_settings.font_size
	gap_between_word_labels.custom_minimum_size.y = Global.words_label_settings.font_size * GAP_SIZE_MULTIPLIER
	value_changed.connect(_sl_value_changed)
