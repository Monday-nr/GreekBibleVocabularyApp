extends HBoxContainer

const SORTED_BY_FREQUENCY_WORDS_PER_BATCH: int = 50

@onready var sort_label: Label = $SortLabel

signal sl_sort_it_changed(_sort_it: int)

var _sort_it: int = 0

func _init() -> void:
	Global.sort_it_setter = self

func _ready() -> void:
	SignalHandler.connect_signal(SignalHandler.Sl.BOOK_CHANGED, _sl_book_changed)
	SignalHandler.connect_signal(SignalHandler.Sl.SORT_MODE_CHANGED, _sl_sort_mode_changed)
	SignalHandler.connect_signal(SignalHandler.Sl.CHAPTER_CHANGED, _reset.unbind(1))
	Global.register_node_with_text($"Prev")
	Global.register_node_with_text($"Next")
	$"Prev".pressed.connect(_sl_prev_button_pressed)
	$"Next".pressed.connect(_sl_next_button_pressed)

func _sl_prev_button_pressed() -> void:
	_change_sort_it(-1)

func _sl_next_button_pressed() -> void:
	_change_sort_it(1)

func _change_sort_it(change: int = 0) -> void:
	var word_num: int = 0
	match Global.get_sort_mode():
		Global.SortMode.MOST_FREQUENT_WORDS_BY_CHAPTER:
			word_num = NewTestament.get_chapter(Global.get_book_it(), Global.get_chapter_it()).get_word_num(false)
		Global.SortMode.MOST_FREQUENT_WORDS_IN_BOOK:
			word_num = NewTestament.get_book(Global.get_book_it()).get_word_num(false)
		_:
			_sort_it = 0
			return
	@warning_ignore("integer_division")
	_sort_it = wrapi(_sort_it + change, 0, int(word_num / SORTED_BY_FREQUENCY_WORDS_PER_BATCH) + 1)
	sort_label.text = "%sMost Frequent %s Words" % [__get_nd(), SORTED_BY_FREQUENCY_WORDS_PER_BATCH]
	sl_sort_it_changed.emit(_sort_it)

func get_words_per_batch() -> int:
	return SORTED_BY_FREQUENCY_WORDS_PER_BATCH

func __get_nd() -> String:
	match _sort_it:
		0: return ""
		1: return "2nd "
		2: return "3rd "
		_: return "%sth " % (_sort_it + 1)

func _reset() -> void:
	_sort_it = 0
	_change_sort_it()

func _sl_book_changed(new_book_it: int) -> void:
	if new_book_it == WordsList.BOOK_IT:
		set_visible(false)
	else:
		match Global.get_sort_mode():
			Global.SortMode.MOST_FREQUENT_WORDS_BY_CHAPTER, \
			Global.SortMode.MOST_FREQUENT_WORDS_IN_BOOK:
				set_visible(true)
			Global.SortMode.ALL_WORDS_IN_CHAPTER, \
			Global.SortMode.WORDS_BY_VERSES:
				set_visible(false)

func _sl_sort_mode_changed(new_sort_mode: Global.SortMode) -> void:
	match new_sort_mode:
		Global.SortMode.MOST_FREQUENT_WORDS_BY_CHAPTER, \
		Global.SortMode.MOST_FREQUENT_WORDS_IN_BOOK:
			set_visible(true)
		Global.SortMode.ALL_WORDS_IN_CHAPTER, \
		Global.SortMode.WORDS_BY_VERSES:
			set_visible(false)
	_reset()
