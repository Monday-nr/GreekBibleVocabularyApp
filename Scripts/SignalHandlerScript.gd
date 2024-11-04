class_name SignalHandler
extends RefCounted

enum Sl {
	LOAD_CONFIG,
	ADVANCED,
	WORDS_LIST_CHANGED,
	BOOK_CHANGED,
	WORD_LIMIT_CHANGED,
	BATCH_CHANGED,
	CHAPTER_CHANGED,
	SORT_MODE_CHANGED,
	SORT_IT_CHANGED,
	VERSE_CHANGED,
	DONE_LOADING,
}

static var _wait_for_tree: bool = true
static var _signals_to_connect: Array[Array] = []

static func connect_signal(signal_id: Sl, callable: Callable) -> void:
	_signals_to_connect.append([signal_id, callable])
	if not _wait_for_tree:
		_connect_signals()

static func _connect_signals() -> void:
	_wait_for_tree = false
	for signal_data: Array[Variant] in _signals_to_connect:
		match signal_data[0]:
			Sl.LOAD_CONFIG:
				SaveLoad.sl_load_config.connect(signal_data[1])
			Sl.ADVANCED:
				Global.word_container.sl_advanced.connect(signal_data[1])
			Sl.WORDS_LIST_CHANGED:
				Global.sl_words_list_changed.connect(signal_data[1])
			Sl.BOOK_CHANGED:
				Global.book_setter.sl_book_changed.connect(signal_data[1])
			Sl.WORD_LIMIT_CHANGED:
				Global.word_limit_setter.sl_word_limit_changed.connect(signal_data[1])
			Sl.BATCH_CHANGED:
				Global.batch_setter.sl_batch_changed.connect(signal_data[1])
			Sl.CHAPTER_CHANGED:
				Global.chapter_setter.sl_chapter_changed.connect(signal_data[1])
			Sl.SORT_MODE_CHANGED:
				Global.sort_mode_setter.sl_sort_mode_changed.connect(signal_data[1])
			Sl.SORT_IT_CHANGED:
				Global.sort_it_setter.sl_sort_it_changed.connect(signal_data[1])
			Sl.VERSE_CHANGED:
				Global.verse_setter.sl_verse_changed.connect(signal_data[1])
			Sl.DONE_LOADING:
				Global.loading_screen.sl_done_loading.connect(signal_data[1])
	_signals_to_connect.clear()
