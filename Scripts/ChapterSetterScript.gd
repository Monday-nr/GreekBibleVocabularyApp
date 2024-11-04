extends HBoxContainer

signal sl_chapter_changed(new_chapter: int)

@onready var chapter_label: Label = $ChapterLabel

var _chapter_it: int = 0
var _updated_for_book: int = -100

func _init() -> void:
	Global.chapter_setter = self

func _ready() -> void:
	SignalHandler.connect_signal(SignalHandler.Sl.BOOK_CHANGED, _sl_book_changed)
	SignalHandler.connect_signal(SignalHandler.Sl.SORT_MODE_CHANGED, _sl_sort_mode_changed)
	Global.register_node_with_text($"Prev")
	Global.register_node_with_text($"Next")
	$"Prev".pressed.connect(_sl_prev_button_pressed)
	$"Next".pressed.connect(_sl_next_button_pressed)

func get_chapter_it() -> int:
	_update_chapter()
	return _chapter_it

func _sl_prev_button_pressed() -> void:
	_update_chapter(-1)

func _sl_next_button_pressed() -> void:
		_update_chapter(1)

func _update_chapter(change: int = 0) -> void:
	var book_it: int = Global.get_book_it()
	if change == 0 and _updated_for_book == book_it:
		return
	_updated_for_book = book_it
	var chapter_num: int = NewTestament.get_book(book_it).get_chapter_num()
	_chapter_it = wrapi(_chapter_it + change, 0, chapter_num)
	chapter_label.text = "Chapter %s" % (_chapter_it + 1)
	sl_chapter_changed.emit(_chapter_it)

func _sl_book_changed(new_book_it: int) -> void:
	set_visible(new_book_it != WordsList.BOOK_IT)

func _sl_sort_mode_changed(new_sort_mode: Global.SortMode) -> void:
	set_visible(new_sort_mode != Global.SortMode.MOST_FREQUENT_WORDS_IN_BOOK)
