extends HBoxContainer

@onready var english_version_label: Label = $EnglishVersionLabel

var _selected_version_it: int = 0

func _ready() -> void:
	SignalHandler.connect_signal(SignalHandler.Sl.DONE_LOADING, _sl_done_loading)
	Global.register_node_with_text($"Prev")
	Global.register_node_with_text($"Next")
	$"Prev".pressed.connect(_sl_prev_button_pressed)
	$"Next".pressed.connect(_sl_next_button_pressed)
	(func(): owner.visibility_changed.connect(_sl_visibility_changed)).call_deferred()

func _update_label() -> void:
	english_version_label.text = "English v.: " + EnglishTranslation.get_version_name(_selected_version_it, true)

func _sl_prev_button_pressed() -> void:
	_selected_version_it = wrapi(_selected_version_it - 1, 0, EnglishTranslation.get_versions_num())
	_update_label()

func _sl_next_button_pressed() -> void:
	_selected_version_it = wrapi(_selected_version_it + 1, 0, EnglishTranslation.get_versions_num())
	_update_label()

func _sl_done_loading() -> void:
	_selected_version_it = EnglishTranslation.get_loaded_version_it()
	_update_label()

func _sl_visibility_changed() -> void:
	if not owner.is_visible():
		if _selected_version_it != EnglishTranslation.get_loaded_version_it():
			Global.loading_screen.display(true)
			await EnglishTranslation.load_version(_selected_version_it)
			var data: Array[Array] = [
				["english_version", "version_idx", _selected_version_it],
			]
			SaveLoad.save(data)
			Global.loading_screen.display(false)
