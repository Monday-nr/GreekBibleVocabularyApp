extends Node

const NUMBER_OF_BOOKS: int = 27
const BOOK_NAMES_AND_CHAPTER_NUM = [
	["Matthew", 28],
	["Mark", 16],
	["Luke", 24],
	["John", 21],
	["Acts", 28],
	["Romans", 16],
	["1_Corinthians", 16],
	["2_Corinthians", 13],
	["Galatians", 6],
	["Ephesians", 6],
	["Philippians", 4],
	["Colossians", 4],
	["1_Thessalonians", 5],
	["2_Thessalonians", 3],
	["1_Timothy", 6],
	["2_Timothy", 4],
	["Titus", 3],
	["Philemon", 1],
	["Hebrews", 13],
	["James", 5],
	["1_Peter", 5],
	["2_Peter", 3],
	["1_John", 5],
	["2_John", 1],
	["3_John", 1],
	["Jude", 1],
	["Revelation", 22],
]

var _books: Array[Book] = []
var _all_words: Array[Word] = []

func create(arr_books: Array[Book]) -> void:
	_books = arr_books
	_books.sort_custom(func(a, b): return get_book_it_by_name(a.name) < get_book_it_by_name(b.name))
	_books.make_read_only()

	for book: Book in _books:
		_all_words.append_array(book.get_all_words())
	_all_words.make_read_only()

func get_all_words() -> Array[Word]:
	return _all_words

func get_book_name(it: int) -> String:
	return BOOK_NAMES_AND_CHAPTER_NUM[it][0]

func get_book_it_by_name(book_name: String) -> int:
	for i: int in BOOK_NAMES_AND_CHAPTER_NUM.size():
		if BOOK_NAMES_AND_CHAPTER_NUM[i][0] == book_name:
			return i
	assert(false, "Book name not found")
	return -1

func get_book(book_it: int) -> Book:
	return _books[book_it]

func get_chapter(book_it: int, chapter_it: int) -> Chapter:
	return _books[book_it].get_chapter(chapter_it)

func get_verse(book_it: int, chapter_it: int, verse_it: int) -> Verse:
	return _books[book_it].get_chapter(chapter_it).get_verse(verse_it)

func get_save_data() -> Array[Dictionary]:
	var save_data: Array[Dictionary] = []
	for book: Book in _books:
		save_data.append(book.get_save_data())
	return save_data
