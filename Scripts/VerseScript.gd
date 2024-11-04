class_name Verse
extends RefCounted

var _words: Array[Word] = []

func _init(arr_words: Array[Word]) -> void:
	_words = arr_words
	_words.make_read_only()

func get_word(it: int) -> Word:
	return _words[it]

func get_words() -> Array[Word]:
	return _words

func get_words_num() -> int:
	return _words.size()

func get_as_string() -> String:
	var verse_string: String = ""
	for word: Word in _words:
		verse_string += word.get_as_string()
		verse_string += " "
	return verse_string

func get_as_array_of_basic_types() -> Array[Dictionary]:
	var arr: Array[Dictionary] = []
	for word: Word in _words:
		arr.append(word._properties)
	return arr

static func create_verse_from_array_of_basic_types(properties_: Array) -> Verse:
	var arr_words: Array[Word] = []
	for dict_props: Dictionary in properties_:
		arr_words.append(Word.new(dict_props))
	return Verse.new(arr_words)
