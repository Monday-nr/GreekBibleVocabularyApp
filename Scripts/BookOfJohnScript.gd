extends RefCounted

# STUFF TO HANDLE RESOURCE FROM BOOK OF JOHN .COM
#
#func _get_array_of_words_of_Book_Of_John(by_chapter: bool, allow_word_duplicates: bool) -> Array[Array]:
	#var book: Array[Array] = []
	#const FOLDER_PATH: String = "res://BookOfJohn/"
	#var file_names: PackedStringArray = DirAccess.get_files_at(FOLDER_PATH)
	#var greek_word_idx: int = 1
	#for file_name: String in file_names:
		#var chapter: Array[Array] = []
		#var file = FileAccess.open(FOLDER_PATH + file_name, FileAccess.READ)
#
		#while not file.eof_reached():
			#var line: String = file.get_line()
			#if line.begins_with(str(greek_word_idx)):
				#greek_word_idx += 1
				#var new_word: Array[String] = __create_word_array_from_line(file, line)
#
				#if allow_word_duplicates or not chapter.has(new_word):
					#chapter.append(new_word)
		#book.append(chapter)
#
	#if by_chapter:
		#return book
	#else:
		#var all_words: Array[Array] = []
		#for chapter: Array[Array] in book:
			#for word: Array[String] in chapter:
				#if allow_word_duplicates or not all_words.has(word):
					#all_words.append(word)
		#return all_words

#func __create_word_array_from_line(file: FileAccess, line: String) ->Array[String]:
	#var word: Array[String] = []
	#word.append(line.split('\t')[1])
	#word.append(file.get_line())
	#word.append(file.get_line())
	#word = __trim_word(word)
	#word.insert(1, BOOK_OF_JOHN_ALL_WORDS_ROMANIZED[word[0]])
	#return word
#
#func _get_array_of_verses_of_Book_Of_John(by_chapter: bool) -> Array[Array]:
	#var book: Array[Array] = []
	#const FOLDER_PATH: String = "res://BookOfJohn/"
	#var file_names: PackedStringArray = DirAccess.get_files_at(FOLDER_PATH)
	#var greek_word_idx: int = 1
	#var chapter_it: int = 1
	#for file_name: String in file_names:
		#var verses: Array[Array] = []
		#var chapter = FileAccess.open(FOLDER_PATH + file_name, FileAccess.READ)
#
		#var verse: Array[Variant] = ["","",[]]
		#while not chapter.eof_reached():
			#var line: String = chapter.get_line()
			#if line.begins_with("John %s" % chapter_it):
#
				## NEXT VERSE REACHED -> ADD PREV VERSE TO CHAPTER
				#var greek_verse: String = ""
				#for word: Array[String] in verse[Verse.WORDS_ARR]:
					#greek_verse += word[0]
					#greek_verse += " "
				#verse[Verse.GREEK] = greek_verse.strip_edges(false, true)
#
				#if verse[0] != "":
					#verses.append(verse)
				#verse = ["","",[]]
				#verse[Verse.ENGLISH] = chapter.get_line()
#
			#if line.begins_with(str(greek_word_idx)):
				#greek_word_idx += 1
				#verse[Verse.WORDS_ARR].append(__create_word_array_from_line(chapter, line))
#
		#book.append(verses)
		#chapter_it += 1
#
	#if by_chapter:
		#return book
	#else:
		#var all_verses: Array[Array] = []
		#for chapter: Array[Array] in book:
			#for verse: Array[String] in chapter:
				#all_verses.append(verse)
		#return all_verses
#
#func _print_book_all_verses_array() -> void:
	#var book: Array[Array] = _get_array_of_verses_of_Book_Of_John(false)
	#var out = FileAccess.open("res://OUTPUT.txt", FileAccess.WRITE)
	#out.store_line("const ARRAY: Array[Array] = [")
	#for verse: Array[Variant] in book:
		#out.store_line("\t[")
		#out.store_line('\t\t"%s",' % verse[Verse.GREEK])
		#out.store_line('\t\t"%s",' % verse[Verse.ENGLISH])
		#out.store_line("\t\t[")
		#for word: Array[String] in verse[Verse.WORDS_ARR]:
			#var line: String = '\t\t\t["%s", "%s", "%s", "%s"],' % word
			#out.store_line(line)
		#out.store_line("\t\t],")
		#out.store_line("\t],")
	#out.store_line("]")
#
#func _print_book_all_verses_by_chapter_array() -> void:
	#var book: Array[Array] = _get_array_of_verses_of_Book_Of_John(true)
	#var out = FileAccess.open("res://OUTPUT.txt", FileAccess.WRITE)
	#out.store_line("const ARRAY: Array[Array] = [")
	#for i: int in book.size():
		#var chapter: Array[Array] = book[i]
		#out.store_line("[ #CHAPTER %s" % (i+1))
		#for verse: Array[Variant] in chapter:
			#out.store_line("\t[")
			#out.store_line('\t\t"%s",' % verse[Verse.GREEK])
			#out.store_line('\t\t"%s",' % verse[Verse.ENGLISH])
#
			#out.store_line("\t\t[")
			#for word: Array[String] in verse[Verse.WORDS_ARR]:
				#var line: String = '\t\t\t["%s", "%s", "%s", "%s"],' % word
				#out.store_line(line)
			#out.store_line("\t\t],")
#
			#out.store_line("\t],")
		#out.store_line("],")
	#out.store_line("]")
#
#func __change_line_in_book() -> void:
	#for i: int in range(1, 22):
			#var file_name: String = "John_Chapter_%02d.txt" % i
			#var orig = FileAccess.open("res://BookOfJohn/" + file_name, FileAccess.READ)
			#var out = FileAccess.open("res://" + file_name, FileAccess.WRITE)
#
			#while not orig.eof_reached():
				#var line: String =  orig.get_line()
				#if line.contains("John %d:" % i) and line.begins_with("Top"):
					#line = line.trim_prefix("Top")
					#line = line.strip_edges()
				#out.store_line(line)
			#orig.close()
			#out.close()
#
#func __print_book_all_words_array() -> void:
	#var out = FileAccess.open("res://OUTPUT.txt", FileAccess.WRITE)
	#var printed_words: Array[Array] = []
	#out.store_line("const ARRAY: Array[Array] = [")
	#for chapter: Array[Array] in BOOK_OF_JOHN_ALL_WORDS_BY_CHAPTER:
		#for word: Array[String] in chapter:
			#if not printed_words.has(word):
				#var line: String = '\t["%s", "%s", "%s", "%s"],' % [word[0], word[1], word[2], word[3]]
				#out.store_line(line)
				#printed_words.append(word)
	#out.store_line("]")
#
#func __print_book_all_words_by_chapter_array() -> void:
	#var out = FileAccess.open("res://OUTPUT.txt", FileAccess.WRITE)
	#out.store_line("const ARRAY: Array[Array] = [")
	#var ch_it = 1
	#for chapter: Array[Array] in BOOK_OF_JOHN_ALL_WORDS_BY_CHAPTER:
		#out.store_line("\t[ //CHAPTER %s" % ch_it)
		#ch_it += 1
		#var printed_words: Array[Array] = []
		#for word: Array[String] in chapter:
			#if not printed_words.has(word):
				#var line: String = '\t\t["%s", "%s", "%s", "%s"],' % [word[0], word[1], word[2], word[3]]
				#out.store_line(line)
				#printed_words.append(word)
		#out.store_line("\t],")
	#out.store_line("]")
#
#func __print_book_all_word_occurance_number() -> void:
	#var out = FileAccess.open("res://OUTPUT.txt", FileAccess.WRITE)
	#var occurances: Dictionary = {}
	#for chapter: Array[Array] in _get_array_of_words_of_Book_Of_John(true, true):
		#for word: Array[String] in chapter:
			#if not occurances.has(word[0]):
				#occurances[word[0]] = 1
			#else:
				#occurances[word[0]] += 1
#
	#var all_words: Array[Array] = BOOK_OF_JOHN_ALL_WORDS.duplicate(true)
	#all_words.sort_custom(func(a, b): return occurances[b[0]] < occurances[a[0]])
	#out.store_line("const DICTIONARY: Dictionary = {")
	#for word: Array[String] in all_words:
		#out.store_line('\t"%s" : %s,' % [word[0], occurances[word[0]]])
	#out.store_line("}")
#
#func __print_book_word_occurance_number_by_chapter() -> void:
	#var out = FileAccess.open("res://OUTPUT.txt", FileAccess.WRITE)
	#out.store_line("const ARRAY: Array[Dictionary] = [")
	#var chapter_it: int = 0
	#for chapter: Array[Array] in _get_array_of_words_of_Book_Of_John(true, true):
		#var occurances: Dictionary = {}
		#for word: Array[String] in chapter:
			#if not occurances.has(word[0]):
				#occurances[word[0]] = 1
			#else:
				#occurances[word[0]] += 1
#
		#var chapter_words: Array[Array] = []
		#chapter_words.assign(BOOK_OF_JOHN_ALL_WORDS_BY_CHAPTER[chapter_it])
		#chapter_words.sort_custom(func(a, b): return occurances[b[0]] < occurances[a[0]])
		#out.store_line("\t{ #CHAPTER %s" % (chapter_it+1))
		#for word: Array[String] in chapter_words:
			#out.store_line('\t\t"%s" : %s,' % [word[0], occurances[word[0]]])
		#out.store_line("\t},")
		#chapter_it += 1
	#out.store_line("]")
#
#func __print_book_all_words_sorted_by_frequency() -> void:
	#var out = FileAccess.open("res://OUTPUT.txt", FileAccess.WRITE)
	#var occurances: Dictionary = BOOK_OF_JOHN_ALL_WORD_OCCURANCE_NUMBERS
	#var all_words: Array[Array] = _get_array_of_words_of_Book_Of_John(false, false)
	#all_words.sort_custom(func(a, b): return occurances[b[0]] < occurances[a[0]])
	#out.store_line("const ARRAY: Array[Array] = [")
	#for word: Array[String] in all_words:
		#out.store_line('\t["%s", "%s", "%s", "%s"],' % word)
	#out.store_line("]")
#
#func __print_book_all_words_by_chapter_sorted_by_frequency() -> void:
	#var out = FileAccess.open("res://OUTPUT.txt", FileAccess.WRITE)
	#var book: Array[Array] = _get_array_of_words_of_Book_Of_John(true, false)
	#out.store_line("const ARRAY: Array[Array] = [")
	#for i: int in book.size():
		#var chapter: Array[Array] = book[i]
		#var occurances: Dictionary = BOOK_OF_JOHN_ALL_WORD_OCCURANCE_NUMBERS_BY_CHAPTERS[i]
		#chapter.sort_custom(func(a, b): return occurances[b[0]] < occurances[a[0]])
		#out.store_line("\t[ #CHAPTER %s" % (i+1))
		#for word: Array[String] in chapter:
			#out.store_line('\t\t["%s", "%s", "%s", "%s"],' % word)
		#out.store_line("\t],")
	#out.store_line("]")
