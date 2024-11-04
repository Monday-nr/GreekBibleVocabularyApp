class_name Word
extends RefCounted

const INT_PROPERTIES: PackedStringArray = [
	"index",
	"hash",
]

var _properties: Dictionary = {}

func _init(props_: Dictionary) -> void:
	__convert_int_properties(props_)
	_properties = props_.duplicate()
	_properties.make_read_only()

func get_property(property: String) -> Variant:
	return _properties[property]

func has_property(property: String) -> bool:
	return _properties[property] != ""

func get_as_string(stripped: bool = false) -> String:
	return _properties["greek_word_in_verse_stripped"] if stripped else _properties["greek_word_in_verse"]

func is_same_word(other_word: Word) -> bool:
	return _properties["greek_word_in_verse_stripped_lower"] == other_word._properties["greek_word_in_verse_stripped_lower"] \
	and _properties["description"] == other_word._properties["description"]

func __convert_int_properties(dict_word: Dictionary) -> void:
	for key: String in INT_PROPERTIES:
		dict_word[key] = int(dict_word[key])

static func filter_duplicates(arr_words: Array[Word]) -> Array[Word]:
	var hashes: Array[int] = []
	var filtered: Array[Word] = []
	for word: Word in arr_words:
		if not hashes.has(word._properties["hash"]):
			hashes.append(word._properties["hash"])
			filtered.append(word)
	return filtered
