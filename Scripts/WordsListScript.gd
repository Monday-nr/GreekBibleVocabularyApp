class_name WordsList
extends RefCounted

const BOOK_IT: int = -1

static var _words_list: Array[Word] = []

static func get_words_list() -> Array[Word]:
	return _words_list

static func is_loaded() -> bool:
	return not _words_list.is_empty()
