extends PanelContainer

const GREEK_VERSE_WORD_SCRIPT = preload("res://Scripts/GreekVerseWordScript.gd")

const HIDDEN_TEXT: String = "- Click To Reveal English Translation -"

@onready var english_label: Label = $MarginContainer/VersesVBox/English
@onready var greek_verse_container: HFlowContainer = $MarginContainer/VersesVBox/GreekVerseContainer

var _verse: Verse
var _verse_english_string: String = ""
var _translation_displayed: bool = false
var _word_labels: Array[Label] = []

func _ready() -> void:
	Controls.register_controls(_enable_controls)
	SignalHandler.connect_signal(SignalHandler.Sl.SORT_MODE_CHANGED, _sl_sort_mode_changed)
	SignalHandler.connect_signal(SignalHandler.Sl.CHAPTER_CHANGED, _sl_chapter_changed)
	SignalHandler.connect_signal(SignalHandler.Sl.BOOK_CHANGED, _sl_book_changed)
	SignalHandler.connect_signal(SignalHandler.Sl.VERSE_CHANGED, _sl_verse_changed)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_display_translation(not _translation_displayed)
			get_viewport().set_input_as_handled()

func _enable_controls(enable: bool) -> void:
	mouse_filter = MOUSE_FILTER_STOP if enable else MOUSE_FILTER_IGNORE

func set_verse(book_it: int, chapter_it: int, verse_it: int, hide_english: bool = true) -> void:
	_verse = NewTestament.get_verse(book_it, chapter_it, verse_it)
	_verse_english_string = EnglishTranslation.get_verse(book_it, chapter_it, verse_it)
	var words: Array[Word] = _verse.get_words()
	var words_num: int = words.size()

	_display_translation(not hide_english)

	if _word_labels.size() < words_num:
		_add_word_labels(words_num - _word_labels.size())

	for i: int in _word_labels.size():
		if i < words_num:
			_word_labels[i].set_word(words[i])
			_word_labels[i].set_visible(true)
		else:
			_word_labels[i].set_visible(false)

func _display_translation(display_: bool) -> void:
	_translation_displayed = display_
	english_label.text = _verse_english_string if _translation_displayed else HIDDEN_TEXT

func toggle_translation() -> void:
	_translation_displayed = not _translation_displayed
	_display_translation(_translation_displayed)

func _add_word_labels(amount: int) -> void:
	for i: int in amount:
		var label := Label.new()
		label.set_script(GREEK_VERSE_WORD_SCRIPT)
		_word_labels.append(label)
		greek_verse_container.add_child(label)

func _clear_greek_verse_container() -> void:
	for child: Node in greek_verse_container.get_children():
		child.queue_free()

func set_background_color(c: Color) -> void:
	$VersesBackground.color = c

func _sl_sort_mode_changed(sort_mode: Global.SortMode) -> void:
	if sort_mode == Global.SortMode.WORDS_BY_VERSES:
		set_verse(Global.get_book_it(), Global.get_chapter_it(), Global.get_verse_it(), true)
		set_visible(true)
	else:
		set_visible(false)

func _sl_verse_changed(verse_it: int) -> void:
	set_verse(Global.get_book_it(), Global.get_chapter_it(), verse_it, true)

func _sl_chapter_changed(new_chapter: int) -> void:
	set_verse(Global.get_book_it(), new_chapter, 0, true)

func _sl_book_changed(new_book_it: int) -> void:
	if new_book_it != WordsList.BOOK_IT and Global.sort_mode_is(Global.SortMode.WORDS_BY_VERSES):
		set_verse(new_book_it, Global.get_chapter_it(), 0, true)
		set_visible(true)
	else:
		set_visible(false)
