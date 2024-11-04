class_name Book
extends RefCounted

var name: String = "placeholder"
var _chapters: Array[Chapter] = []
var _all_words: Array[Word] = []
var _all_words_sorted_by_frequency: Array[Word] = []
var _word_occurance_numbers_by_hash: Dictionary = {}

func _init(name_:String, arr_chapters: Array[Chapter]) -> void:
	name = name_
	_chapters = arr_chapters
	_chapters.make_read_only()

	for chapter: Chapter in _chapters:
		_all_words.append_array(chapter.get_all_words())
		_word_occurance_numbers_by_hash = Global.combine_dictionaries(_word_occurance_numbers_by_hash, chapter._word_occurance_numbers_by_hash)
	_all_words.make_read_only()
	_word_occurance_numbers_by_hash.make_read_only()

	_all_words_sorted_by_frequency = Word.filter_duplicates(_all_words.duplicate())
	_all_words_sorted_by_frequency.sort_custom(func(a, b): return _word_occurance_numbers_by_hash[b._properties["hash"]] < _word_occurance_numbers_by_hash[a._properties["hash"]])
	_all_words_sorted_by_frequency.make_read_only()

func get_chapter(it: int) -> Chapter:
	return _chapters[it]

func get_chapters() -> Array[Chapter]:
	return _chapters

func get_chapter_num() -> int:
	return _chapters.size()

func get_all_words() -> Array[Word]:
	return _all_words

func get_word_num(include_duplicates: bool = true) -> int:
	return _all_words.size() if include_duplicates else _all_words_sorted_by_frequency.size()

func get_all_words_sorted_by_frequency() -> Array[Word]:
	return _all_words_sorted_by_frequency

func get_word_occurance_num_in_book(word: Word) -> int:
	if _word_occurance_numbers_by_hash.has(word.hash):
		return _word_occurance_numbers_by_hash[word.hash]
	return 0

func get_as_array_of_basic_types() -> Array[Array]:
	var arr: Array[Array] = []
	for chapter: Chapter in _chapters:
		arr.append(chapter.get_as_array_of_basic_types())
	return arr

func get_save_data() -> Dictionary:
	var save_data_dict: Dictionary = {
		"book_name" : name,
		"chapters" : get_as_array_of_basic_types(),
	}
	return save_data_dict

static func create_book_from_save_data(save_data: Dictionary) -> Book:
	var arr_chapters: Array[Chapter] = []
	for arr_verses: Array in save_data.chapters:
		arr_chapters.append(Chapter.create_chapter_from_array_of_basic_types(arr_verses))
	return Book.new(save_data.book_name, arr_chapters)
