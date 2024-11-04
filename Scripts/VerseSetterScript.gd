extends HBoxContainer

@onready var _verse_it_label: Label = $VerseLabel

signal sl_verse_changed(new_verse_it: int)

var _verse_it: int = 0

func _init() -> void:
	Global.verse_setter = self

func _ready() -> void:
	Global.register_node_with_text($"Prev")
	Global.register_node_with_text($"Next")
	SignalHandler.connect_signal(SignalHandler.Sl.DONE_LOADING, _update_verse)
	SignalHandler.connect_signal(SignalHandler.Sl.CHAPTER_CHANGED, _reset.unbind(1))
	SignalHandler.connect_signal(SignalHandler.Sl.BOOK_CHANGED, _sl_book_changed)
	SignalHandler.connect_signal(SignalHandler.Sl.SORT_MODE_CHANGED, _sl_sort_mode_changed)
	$"Prev".pressed.connect(_sl_prev_button_pressed)
	$"Next".pressed.connect(_sl_next_button_pressed)

func _update_verse(new_it: int = _verse_it, wrap_it: bool = true) -> void:
	var verse_num_in_chapter: int = NewTestament.get_chapter(Global.get_book_it(), Global.get_chapter_it()).get_verse_num()
	if wrap_it:
		_verse_it = wrapi(new_it, 0, verse_num_in_chapter)
	else:
		_verse_it = clampi(new_it, 0, verse_num_in_chapter)
	_verse_it_label.text = "Verse: %s of %s" % [_verse_it + 1, verse_num_in_chapter]

func _reset() -> void:
	_update_verse(0)

func get_verse_it() -> int:
	_update_verse(_verse_it, false)
	return _verse_it

func _sl_prev_button_pressed() -> void:
	_update_verse(_verse_it - 1)
	sl_verse_changed.emit(_verse_it)

func _sl_next_button_pressed() -> void:
	_update_verse(_verse_it + 1)
	sl_verse_changed.emit(_verse_it)

func _sl_book_changed(new_book_it: int) -> void:
	_reset()
	set_visible(new_book_it != WordsList.BOOK_IT and Global.sort_mode_is(Global.SortMode.WORDS_BY_VERSES))

func _sl_sort_mode_changed(new_sort_mode: Global.SortMode) -> void:
	set_visible(new_sort_mode == Global.SortMode.WORDS_BY_VERSES)
