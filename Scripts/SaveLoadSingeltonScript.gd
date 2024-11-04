extends Node

signal sl_load_config(config_file: ConfigFile)

var config_file_path: String = get_containing_folder_path() + "config.cfg"

var _has_config_file: bool = false
var _config_file := ConfigFile.new()

func _init() -> void:
	if not FileAccess.file_exists(config_file_path):
		var f := FileAccess.open(config_file_path, FileAccess.WRITE)
		f.close()
	var err: int = _config_file.load(config_file_path)
	_has_config_file = (err == OK)

func get_containing_folder_path() -> String:
	var exe_path: String = OS.get_executable_path()
	return exe_path.left(exe_path.rfind("/")) + "/"

func _load_config() -> void:
	if _has_config_file:
		sl_load_config.emit(_config_file)

var __save_data: Dictionary = {}
func save(arr_data: Array[Array], force_no_delay: bool = false) -> void:
	if not _has_config_file:
		return
	if not force_no_delay:
		if __save_data.is_empty():
			create_tween().tween_callback(func():
				__save_dict(__save_data)
				__save_data.clear()
				).set_delay(1.5)
		for data: Array[Variant] in arr_data:
				__save_data[data[0]] = Dictionary()
		for data: Array[Variant] in arr_data:
			__save_data[data[0]][data[1]] = data[2]
	else:
		__save_arr(arr_data)

func __save_arr(arr_data: Array[Variant]) -> void:
	for data: Array[Variant] in arr_data:
		_config_file.set_value(data[0], data[1], data[2])
	if not __save_data.is_empty():
		__save_dict(__save_data)
	else:
		_config_file.save(config_file_path)

func __save_dict(dict_data: Dictionary) -> void:
	if dict_data.is_empty():
		return
	for section: String in dict_data.keys():
		for key: String in dict_data[section].keys():
			_config_file.set_value(section, key, dict_data[section][key])
	_config_file.save(config_file_path)

func get_saved_english_translation_version() -> int:
	if _has_config_file:
		if _config_file.has_section("english_version"):
			return int(_config_file.get_value("english_version", "version_idx"))
	return EnglishTranslation.DEFAULT_VERSION
