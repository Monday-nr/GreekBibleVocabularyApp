extends Label

var _word: Word

func _ready() -> void:
	Controls.register_controls(_enable_controls, false)
	label_settings = Global.verse_label_settings
	mouse_filter = MouseFilter.MOUSE_FILTER_STOP
	#focus_entered.connect(_sl_focus_entered)
	#focus_exited.connect(_sl_focus_exited)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			Global.set_word(_word, true)
			get_viewport().set_input_as_handled()

func _enable_controls(enable: bool) -> void:
	mouse_filter = MOUSE_FILTER_STOP if enable else MOUSE_FILTER_IGNORE

func set_word(word_: Word) -> void:
	_word = word_
	text = _word.get_as_string(false) + " "


func _sl_focus_entered() -> void:
	print("ENT")

func _sl_focus_exited() -> void:
	print("EXT")
