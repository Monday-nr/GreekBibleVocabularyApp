class_name ResourceHandler
extends RefCounted

const NEW_TESTAMENT_JSON_PATH: String = "res://NewTestament.json"
const ALWAYS_LOAD_FROM_CSV: bool = false

static var _progress: float = 0.0
static var _progress_amount: float = (100.0 / 27.0) / 2

static func _update_progress(amount: float = _progress_amount) -> void:
	_progress += amount
	Global.loading_screen.call_deferred("set_progress", _progress)

static func _reset_progress() -> void:
	_progress = 0.0
	Global.loading_screen.call_deferred("set_progress", _progress)

static func load_new_testament(save_as_json: bool = true) -> bool:
	if not ALWAYS_LOAD_FROM_CSV and _new_testament_json_exist():
		NewTestament.create(await _load_new_testamnet_json())
	else:
		NewTestament.create(await _read_new_testament_from_file())
		if save_as_json:
			__save_new_testament_as_json()
	return true

static func _read_new_testament_from_file() -> Array[Book]:
	var loaded_books: Array[Book] = []
	var mutex := Mutex.new()
	var folder_path: String = get_resource_folder_path() + "/NewTestament"
	var book_names: PackedStringArray = DirAccess.get_directories_at(folder_path)

	var task_id: int = WorkerThreadPool.add_group_task(__read_new_testament_book_from_file.bind(loaded_books, mutex, folder_path, book_names), book_names.size(), -1, true)
	while not WorkerThreadPool.is_group_task_completed(task_id):
		await Global.await_frames(1)
	WorkerThreadPool.wait_for_group_task_completion(task_id)

	return loaded_books

static func __read_new_testament_book_from_file(book_idx: int, loaded_books: Array[Book], mutex: Mutex, folder_path: String, book_names: PackedStringArray) -> void:
	#_reset_progress()
	var book_name: String = book_names[book_idx]
	var book_path = folder_path + "/" + book_name
	var arr_loaded_chapters: Array[Chapter] = []
	var chapter_names: PackedStringArray = DirAccess.get_directories_at(book_path)

	for chapter_name: String in chapter_names:
		var loaded_chapter: Array[Verse] = []
		var chapter_path: String = book_path + "/" + chapter_name
		var verse_names: PackedStringArray = DirAccess.get_files_at(chapter_path)

		for verse_name: String in verse_names:
			var loaded_verse: Array[Word] = []
			var verse_path: String = chapter_path + "/" + verse_name
			var file_access := FileAccess.open(verse_path, FileAccess.READ)

			var properties: PackedStringArray = file_access.get_csv_line(",")

			while not file_access.eof_reached():
				var line: PackedStringArray = file_access.get_csv_line(",")
				if line[0] != "":
					var dict_word: Dictionary = create_dict_from_packed_string_arrays(properties, line)
					loaded_verse.append(Word.new(dict_word))
				else:
					break

			loaded_chapter.append(Verse.new(loaded_verse))
		arr_loaded_chapters.append(Chapter.new(loaded_chapter))
	var loaded_book := Book.new(book_name, arr_loaded_chapters)
	#print("Loaded ", book_name)
	mutex.lock()
	loaded_books.append(loaded_book)
	mutex.unlock()
	_update_progress()

static func _new_testament_json_exist() -> bool:
	return FileAccess.file_exists(NEW_TESTAMENT_JSON_PATH)

static func __save_new_testament_as_json() -> void:
	var file := FileAccess.open(NEW_TESTAMENT_JSON_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(NewTestament.get_save_data()))

static func _load_new_testamnet_json() -> Array[Book]:
	#_reset_progress()
	var loaded_books: Array[Book] = []
	var file := FileAccess.open(NEW_TESTAMENT_JSON_PATH, FileAccess.READ)
	var loaded_data: Array = JSON.parse_string(file.get_as_text())
	var task_id: int = WorkerThreadPool.add_group_task(__load_book_from_saved_data.bind(loaded_data, loaded_books), loaded_data.size(), -1, true)
	while not WorkerThreadPool.is_group_task_completed(task_id):
		await Global.await_frames(1)
	WorkerThreadPool.wait_for_group_task_completion(task_id)
	return loaded_books

static func __load_book_from_saved_data(index: int, data: Array, arr_books: Array[Book]) -> void:
	arr_books.append(Book.create_book_from_save_data(data[index]))
	#print("Loaded ", arr_books[-1].name)
	_update_progress()


static func load_english_bible(version_it: int) -> bool:
	_reset_progress()
	version_it += 1 # csv column num is version_it + 1
	var file_access := FileAccess.open("res://english_translations.csv", FileAccess.READ)

	var csv_line: PackedStringArray = file_access.get_csv_line()
	csv_line.remove_at(0)
	EnglishTranslation._version_names_short = csv_line
	csv_line = file_access.get_csv_line()
	csv_line.remove_at(0)
	EnglishTranslation._version_names = csv_line

	var books: Array[Array] = []
	var new_book: Array[Array] = []
	var new_chapter: Array[String] = []

	var current_book_name: String = "Matthew"
	var current_chapter_it: int = 1

	while not file_access.eof_reached():
		csv_line = file_access.get_csv_line()

		if csv_line[0] == "":
			new_book.append(new_chapter)
			books.append(new_book)
			break

		var slices: PackedStringArray = csv_line[0].split(" ", 2)
		var book_name: String
		book_name = slices[0] + slices[1] if 2 < slices.size() else slices[0]
		slices = slices[-1].split(":", 1)
		var chapter_it: int = int(slices[0])

		if book_name != current_book_name:
			current_book_name = book_name
			current_chapter_it = chapter_it
			new_book.append(new_chapter.duplicate())
			books.append(new_book.duplicate())
			new_chapter.clear()
			new_book.clear()
			_update_progress()
			await Global.await_frames(1)
		elif chapter_it != current_chapter_it:
			current_chapter_it = chapter_it
			new_book.append(new_chapter.duplicate())
			new_chapter.clear()
		new_chapter.append(csv_line[version_it])

	EnglishTranslation._books = books
	return true

#func read_words_list() -> void:
	#var words_list: Array[Word] =[]
	#const FILE_NAMES: Array[String] = [ "words", "Words", "WORDS"]
	#var words_path: String = get_containing_folder_path() + "%s.txt"
	#var file: FileAccess
	#for n: String in FILE_NAMES:
		#if FileAccess.file_exists(words_path % n):
			#file = FileAccess.open(words_path % n, FileAccess.READ)
			#break
#
	#if file == null:
		#_words_list.append(["Empty", "Empty", "Empty"])
		#message.display("ERROR: NO WORDS.TXT FILE FOUND")
		#return
#
	#while not file.eof_reached():
		#var line: String = file.get_line()
#
		#if line.is_empty():
			#continue
#
		#var new_word: PackedStringArray = line.split(",", false, 2)
		#if new_word.size() != 3:
			#continue
		#new_word.insert(2, "-")
		#_words_list.append(__trim_word(new_word))
#
	#if _words_list.is_empty():
		#_words_list.append(["Empty", "Empty", "Empty"])
		#message.display("ERROR: NO WORDS FOUND IN FILE")
		#return
#
#func __trim_word(strings: Array[String]) -> Array[String]:
	#const CHARS_TO_TRIM: Array[String] = ['"', ' ', ',']
	#for i: int in strings.size():
		#strings[i] = strings[i].strip_edges()
		#strings[i] = strings[i].replacen('\"', '')
		#for c: String in CHARS_TO_TRIM:
			#strings[i] = strings[i].trim_prefix(c)
			#strings[i] = strings[i].trim_suffix(c)
	#return strings

static func create_dict_from_packed_string_arrays(keys: PackedStringArray, values: PackedStringArray) -> Dictionary:
	var new_dict: Dictionary = {}
	for i: int in keys.size():
		new_dict[keys[i]] = values[i]
	return new_dict

static func get_resource_folder_path() -> String:
	var folder_path: String = SaveLoad.get_containing_folder_path()
	if not is_release_build():
		const SAVE_FOLDER_PATH_RELATIVE_TO_GODOT: String = "BIBLE_RESOURCES/GodotProjects/GreekStudyApp/GreekStudyApp/Resources"
		folder_path += SAVE_FOLDER_PATH_RELATIVE_TO_GODOT
	return folder_path

static func is_release_build() -> bool:
	return OS.has_feature("release")


## LOAD NT NON-THREADED
#func load_new_testament() -> Array[Book]:
	#var folder_path: String = get_resource_folder_path()
	#folder_path += "/NewTestament"
#
	#var loaded_books: Array[Book] = []
	#var book_names: PackedStringArray = DirAccess.get_directories_at(folder_path)
#
	#for book_name: String in book_names:
		#print("Loading ", book_name)
		#var loaded_book: Array[Chapter] = []
		#var book_path: String = folder_path + "/" + book_name
		#var chapter_names: PackedStringArray = DirAccess.get_directories_at(book_path)
#
		#for chapter_name: String in chapter_names:
			#var loaded_chapter: Array[Verse] = []
			#var chapter_path: String = book_path + "/" + chapter_name
			#var verse_names: PackedStringArray = DirAccess.get_files_at(chapter_path)
#
			#for verse_name: String in verse_names:
				#var loaded_verse: Array[Word] = []
				#var verse_path: String = chapter_path + "/" + verse_name
				#var file_access := FileAccess.open(verse_path, FileAccess.READ)
				#var properties: PackedStringArray = file_access.get_csv_line(",")
#
				#while not file_access.eof_reached():
					#var line: PackedStringArray = file_access.get_csv_line(",")
					#if line[0] != "":
						#var dict_word: Dictionary = Global.create_dict_from_packed_string_arrays(properties, line)
						#__convert_int_properties(dict_word)
						#loaded_verse.append(Word.new(dict_word))
					#else:
						#break
#
				#loaded_chapter.append(Verse.new(loaded_verse))
			#loaded_book.append(Chapter.new(loaded_chapter))
		#loaded_books.append(Book.new(book_name, loaded_book))
		#sl_book_loaded.emit(book_name)
		#await Global.await_frames(1)
#
	#return loaded_books
