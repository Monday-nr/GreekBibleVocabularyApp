class_name Chapter
extends RefCounted

var _verses: Array[Verse] = []
var _all_words: Array[Word] = []
var _all_words_sorted_by_frequency: Array[Word] = []
var _word_occurance_numbers_by_hash: Dictionary = {}

func _init(arr_verses: Array[Verse]) -> void:
	_verses = arr_verses
	_verses.make_read_only()

	for verse: Verse in _verses:
		_all_words.append_array(verse.get_words())
	_all_words.make_read_only()

	for word: Word in _all_words:
		if _word_occurance_numbers_by_hash.has(word._properties["hash"]):
			_word_occurance_numbers_by_hash[word._properties["hash"]] += 1
		else:
			_word_occurance_numbers_by_hash[word._properties["hash"]] = 1
	_word_occurance_numbers_by_hash.make_read_only()

	_all_words_sorted_by_frequency = Word.filter_duplicates(_all_words.duplicate())
	_all_words_sorted_by_frequency.sort_custom(func(a, b): return _word_occurance_numbers_by_hash[b._properties["hash"]] < _word_occurance_numbers_by_hash[a._properties["hash"]])
	_all_words_sorted_by_frequency.make_read_only()


func get_verse(it: int) -> Verse:
	return _verses[it]

func get_verses() -> Array[Verse]:
	return _verses

func get_verse_num() -> int:
	return _verses.size()

func get_word_num(include_duplicates: bool = true) -> int:
	return _all_words.size() if include_duplicates else _all_words_sorted_by_frequency.size()

func get_all_words() -> Array[Word]:
	return _all_words

func get_all_words_sorted_by_frequency() -> Array[Word]:
	return _all_words_sorted_by_frequency

func get_word_occurance_num_in_chapter(word: Word) -> int:
	if _word_occurance_numbers_by_hash.has(word.hash):
		return _word_occurance_numbers_by_hash[word.hash]
	return 0

func get_as_array_of_basic_types() -> Array[Array]:
	var arr: Array[Array] = []
	for verse: Verse in _verses:
		arr.append(verse.get_as_array_of_basic_types())
	return arr

static func create_chapter_from_array_of_basic_types(arr_verses: Array) -> Chapter:
	var verses: Array[Verse] = []
	for arr_word_properties: Array in arr_verses:
		verses.append(Verse.create_verse_from_array_of_basic_types(arr_word_properties))
	return Chapter.new(verses)
