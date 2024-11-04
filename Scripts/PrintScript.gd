class_name Print
extends RefCounted

static var _out := FileAccess.open("res://OUTPUT.txt", FileAccess.WRITE)

static func out(string: String) -> void:
	_out.store_line(string)

static func out_translation() -> void:
	var book_it: int = 0
	for book: Array[Array] in EnglishTranslation._books:
		_out.store_line("")
		_out.store_line("")
		_out.store_line(NewTestament.get_book_name(book_it))
		_out.store_line("")
		var chapter_it: int = 1
		for chapter: Array[String] in book:
			var verse_it: int = 1
			_out.store_line("")
			_out.store_line("Chapter %s" % chapter_it)
			_out.store_line("")
			for verse: String in chapter:
				_out.store_line("%s:%s %s" % [chapter_it, verse_it, verse])
				verse_it += 1
			chapter_it += 1
		book_it += 1

static func out_books() -> void:
	for book: Book in NewTestament._books:
		out_book(book)

static func out_book_by_it(book_it: int) -> void:
	out_book(NewTestament.get_book(book_it))

static func out_book(book: Book) -> void:
	_out.store_line(book.name)
	var chapter_it: int = 1
	for chapter: Chapter in book._chapters:
		_out.store_line("")
		_out.store_line("Chapter %s" % chapter_it)
		out_chapter(chapter)
		chapter_it += 1
	_out.store_line("")

static func out_chapter(chapter: Chapter) -> void:
	var verse_it: int = 1
	_out.store_line("")
	for verse: Verse in chapter._verses:
		_out.store_line("%s %s" % [verse_it, verse.get_as_string()])
		verse_it += 1

static func out_dictionary(dict: Dictionary) -> void:
	for key: Variant in dict:
		_out.store_line("%s : %s" % [key, dict[key]])

static func out_words_by_occurances_in_book(book: Book) -> void:
	for word: Word in book._all_words_sorted_by_frequency:
		_out.store_line("%s : %s" % [word.get_property("greek_word_in_verse_stripped_lower"), book._word_occurance_numbers_by_hash[word.get_property("hash")]])

static func book(book: Book) -> void:
	print(book.name)
	var chapter_it: int = 1
	for chapter: Chapter in book._chapters:
		print("")
		print("Chapter %s" % chapter_it)
		out_chapter(chapter)
		chapter_it += 1
	print("")

static func chapter(chapter: Chapter) -> void:
	var verse_it: int = 1
	print("")
	for verse: Verse in chapter._verses:
		print("%s %s" % [verse_it, verse.get_as_string()])
		verse_it += 1
