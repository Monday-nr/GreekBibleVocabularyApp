class_name EnglishTranslation
extends RefCounted

const DEFAULT_VERSION: int = 0

static var _version_names: PackedStringArray = []
static var _version_names_short: PackedStringArray = []
static var _books: Array[Array] = []
static var _loaded_version_it: int = -1

static func get_verse(book_it: int, chapter_it: int, verse_it: int) -> String:
	return _books[book_it][chapter_it][verse_it]

static func load_version(version: int) -> bool:
	if _loaded_version_it == version:
		return true
	_loaded_version_it = version
	await ResourceHandler.load_english_bible(version)
	return true

static func get_loaded_version_it() -> int:
	return _loaded_version_it

static func get_versions_num() -> int:
	return _version_names.size()

static func get_version_name(v: int = _loaded_version_it, short: int = false) -> String:
	return _version_names_short[v] if short else _version_names[v]
