extends VBoxContainer

const WORDS_DEFAULT_POS_Y: int = 10
const SCROLL_SPEED: int = 20

signal sl_advanced

@onready var word_label_1: Label = $WordLabel1
@onready var word_label_2: Label = $WordLabel2
@onready var word_label_3: Label = $WordLabel3
@onready var word_label_4: Label = $WordLabel4
@onready var word_label_5: Label = $WordLabel5

var _current_word: Word

func _ready() -> void:
	Global.word_container = self

	Controls.register_controls(_enable_controls)
	SignalHandler.connect_signal(SignalHandler.Sl.BOOK_CHANGED, _sl_book_changed)
	SignalHandler.connect_signal(SignalHandler.Sl.WORDS_LIST_CHANGED, _sl_word_changed.unbind(1))
	SignalHandler.connect_signal(SignalHandler.Sl.BATCH_CHANGED, _sl_word_changed)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			get_viewport().set_input_as_handled()
			_advance_words()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			__scroll(SCROLL_SPEED)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			__scroll(-SCROLL_SPEED)
		else:
			return
		get_viewport().set_input_as_handled()

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("advance"):
		_advance_words()
	elif event.is_action_pressed("ui_up", true):
		__scroll(SCROLL_SPEED)
	elif event.is_action_pressed("ui_down", true):
		__scroll(-SCROLL_SPEED)
	else:
		return
	get_viewport().set_input_as_handled()

func __scroll(amount: float) -> void:
	position.y += amount
	Global.settings_container.hide()

func _enable_controls(enable: bool) -> void:
	mouse_filter = MOUSE_FILTER_STOP if enable else MOUSE_FILTER_IGNORE
	set_process_unhandled_input(enable)
	set_process_unhandled_key_input(enable)

func _advance_words() -> void:
	if word_label_4.is_visible():
		set_word(Global.get_word(true))
	elif word_label_2.is_visible():
		word_label_3.set_visible(true)
		word_label_4.set_visible(true)
		word_label_5.set_visible(true)
		word_label_1.text = "%s - %s" % [word_label_1.text, _current_word.get_property("parsing")]
	else:
		word_label_2.set_visible(true)
	sl_advanced.emit()

func set_word(word: Word, show_translation: bool = false) -> void:
	position.y = WORDS_DEFAULT_POS_Y
	if Global.is_using_word_list():
		assert(false, "set_word not implemented for words_list")
	else:
		if Global.sort_mode_is(Global.SortMode.WORDS_BY_VERSES):
			word_label_1.text = word.get_property("greek_word_in_verse_stripped")
		else:
			word_label_1.text = word.get_property("greek_word_in_verse_stripped_lower")

		word_label_2.text = "{ %s }" % word.get_property("transliteration")
		word_label_2.set_visible(show_translation)

		if word.has_property("greek_base_word"):
			word_label_3.text = "%s { %s }" % [word.get_property("greek_base_word"), word.get_property("greek_base_word_transliteration")]
			word_label_3.set_visible(show_translation)
		else:
			word_label_3.set_visible(false)

		word_label_4.text = word.get_property("english_translation")
		word_label_4.set_visible(show_translation)

		word_label_5.text = word.get_property("greekbible_definition")
		word_label_5.set_visible(show_translation)

	_current_word = word

func _sl_book_changed(new_book_it: int) -> void:
	word_label_3.set_visible(new_book_it != WordsList.BOOK_IT)

func _sl_word_changed() -> void:
	await Global.await_frames(1)
	set_word(Global.get_word(false))
