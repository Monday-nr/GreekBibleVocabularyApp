extends Node

var menu_label_settings = preload("res://PreferencesUI/MenuLabelSettings.tres")
var verse_label_settings = preload("res://PreferencesUI/VersesLabelSettings.tres")
var words_label_settings = preload("res://PreferencesUI/WordsLabelSettings.tres")

var loading_screen: ColorRect
var message: PanelContainer
var main: CanvasLayer
var settings_container: PanelContainer
var word_container: VBoxContainer
var book_setter: HBoxContainer
var chapter_setter: HBoxContainer
var word_limit_setter: HBoxContainer
var batch_setter: HBoxContainer
var sort_mode_setter: HBoxContainer
var sort_it_setter: HBoxContainer
var verse_setter: HBoxContainer

var new_testament: Array[Array] = []


signal sl_words_list_changed(new_list: Array[Array])

enum SortMode {
	ALL_WORDS_IN_CHAPTER,
	MOST_FREQUENT_WORDS_BY_CHAPTER,
	MOST_FREQUENT_WORDS_IN_BOOK,
	WORDS_BY_VERSES,
}
var _nodes_with_text: Array[Node] = []
var _backgrounds: Array[ColorRect] = []
var _alternate_backgrounds: Array[ColorRect] = []

var _current_words_list: Array[Word] = []
var _word_it: int = 0

func _ready() -> void:
	SignalHandler.connect_signal(SignalHandler.Sl.BOOK_CHANGED, _update_words_list.unbind(1))
	SignalHandler.connect_signal(SignalHandler.Sl.CHAPTER_CHANGED, _update_words_list.unbind(1))
	SignalHandler.connect_signal(SignalHandler.Sl.SORT_MODE_CHANGED, _update_words_list.unbind(1))
	SignalHandler.connect_signal(SignalHandler.Sl.SORT_IT_CHANGED, _update_words_list.unbind(1))
	SignalHandler.connect_signal(SignalHandler.Sl.VERSE_CHANGED, _update_words_list.unbind(1))

	#_read_words_list()
	#_current_words_list = _words_list.duplicate(true)


func register_node_with_text(node: Node) -> void:
	if not _nodes_with_text.has(node):
		_nodes_with_text.append(node)

func register_background(background: ColorRect) -> void:
	_backgrounds.append(background)

func register_alternate_background(background: ColorRect) -> void:
	_alternate_backgrounds.append(background)

func get_nodes_with_text() -> Array[Node]:
	return _nodes_with_text

func get_backgrounds() -> Array[ColorRect]:
	return _backgrounds

func get_alternate_backgrounds() -> Array[ColorRect]:
	return _alternate_backgrounds

func get_current_list_length() -> int:
	return _current_words_list.size()

func get_word_limit() -> int:
	return word_limit_setter._word_limit

func get_batch_start() -> int:
	return batch_setter._batch_start

func get_batch_end() -> int:
	return batch_setter._batch_end

func get_batch_it() -> int:
	return batch_setter._batch_it

func get_book_it() -> int:
	return book_setter._book_it

func get_chapter_it() -> int:
	return chapter_setter.get_chapter_it()

func get_verse_it() -> int:
	return verse_setter.get_verse_it()

func get_sort_it() -> int:
	return sort_it_setter._sort_it

func get_sort_mode() -> SortMode:
	return sort_mode_setter._sort_mode as SortMode

func sort_mode_is(sort_mode_: SortMode) -> bool:
	return get_sort_mode() == sort_mode_

func is_using_word_list() -> bool:
	assert(get_book_it() != WordsList.BOOK_IT, "Words list not implemented")
	return get_book_it() == WordsList.BOOK_IT

func set_word(word: Word, show_translaton: bool) -> void:
	word_container.set_word(word, show_translaton)

func get_word(advance_it: bool = true) -> Word:
	var min_it: int
	var max_it: int
	if __should_ignore_word_limit():
		min_it = 0
		max_it = _current_words_list.size()
	else:
		min_it = get_batch_start()
		max_it = get_batch_end()
	_word_it = wrapi(_word_it + int(advance_it), min_it, max_it)
	return _current_words_list[_word_it]

func __should_ignore_word_limit() -> bool:
	return not is_using_word_list() and sort_mode_is(SortMode.WORDS_BY_VERSES)

func _reset_word_it() -> void:
	_word_it = 0 if __should_ignore_word_limit() else get_batch_start()

func _update_words_list() -> void:
	if is_using_word_list():
		pass
		#_current_words_list = _words_list.duplicate(true)
		#_current_words_list.shuffle()
	else:
		match get_sort_mode():
			SortMode.ALL_WORDS_IN_CHAPTER:
				_current_words_list.assign(NewTestament.get_chapter(get_book_it(), get_chapter_it()).get_all_words_sorted_by_frequency()) ## GETTING get_all_words_sorted_by_frequency BECAUSE IT'S ALREADY FILTERED FROM DUPLICATES, THE SORTING DOESN'T MATTER SINCE IT'S SHUFFLED
				_current_words_list.shuffle()
			SortMode.MOST_FREQUENT_WORDS_BY_CHAPTER:
				_current_words_list = __get_slice_of_words_list(NewTestament.get_chapter(get_book_it(), get_chapter_it()).get_all_words_sorted_by_frequency(), sort_it_setter.get_words_per_batch(), true)
			SortMode.MOST_FREQUENT_WORDS_IN_BOOK:
				_current_words_list = __get_slice_of_words_list(NewTestament.get_book(get_book_it()).get_all_words_sorted_by_frequency(), sort_it_setter.get_words_per_batch(), true)
			SortMode.WORDS_BY_VERSES:
				_current_words_list.assign(Word.filter_duplicates(NewTestament.get_verse(get_book_it(), get_chapter_it(), get_verse_it()).get_words()))
				#_current_words_list.shuffle()
	sl_words_list_changed.emit(_current_words_list)
	_reset_word_it()

func __get_slice_of_words_list(list: Array[Word], slice_size: int, randomized: bool) -> Array[Word]:
	var it: int = get_sort_it()
	var start: int = it * slice_size
	var end: int = start + slice_size
	if list.size() < end:
		end = list.size()
	var new_list: Array[Word] = []
	new_list.assign(list.slice(start, end))
	if randomized:
		new_list.shuffle()
	return new_list


################## UTILS ##########################


func get_all_child_nodes(node: Node) -> Array[Node]:
	var all_child_nodes: Array[Node] = []
	for child in node.get_children():
		all_child_nodes.append_array(get_all_child_nodes(child))
	return all_child_nodes

func await_frames(num: int) -> bool:
	for i: int in num:
		await get_tree().process_frame
	return true

func await_nodes(nodes: Array[Node]) -> bool:
	var is_ready: bool = false
	while not is_ready:
		is_ready = true
		for node: Node in nodes:
			if not node.is_node_ready():
				is_ready = false
				await Global.await_frames(1)
				break
	return true

## COMBINE DICTIONARIES WITH INT / FLOAT VALUES
func combine_dictionaries(dict1: Dictionary, dict2: Dictionary) -> Dictionary:
	var combined_dict: Dictionary = dict1.duplicate()
	for key: Variant in dict2.keys():
		if combined_dict.has(key):
			combined_dict[key] += dict2[key]
		else:
			combined_dict[key] = dict2[key]
	return combined_dict
