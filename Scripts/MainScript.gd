extends CanvasLayer

const DEFAULT_WINDOW_SIZE := Vector2i(900, 650)

@onready var settings: PanelContainer = $SettingsContainer
@onready var words_container: VBoxContainer = $Words

func _ready() -> void:
	Global.main = self
	SignalHandler.connect_signal(SignalHandler.Sl.LOAD_CONFIG, _sl_load_config)
	get_viewport().get_window().grab_focus()

var _ui_visible: bool = true
func set_ui_visible(vis: bool) -> void:
	_ui_visible = vis
	settings.set_visible(vis)

func _sl_load_config(config_file_: ConfigFile) -> void:
	var window: Window = get_viewport().get_window()
	if config_file_.has_section("window_size"):
		window.size = Vector2i(
			config_file_.get_value("window_size", "width"),
			config_file_.get_value("window_size", "height")
			)
	else:
		window.size = DEFAULT_WINDOW_SIZE
	_sl_viewport_size_changed(false)

	if config_file_.has_section("window_position"):
		window.position = Vector2i(
			config_file_.get_value("window_position", "x"),
			config_file_.get_value("window_position", "y")
			)
	get_viewport().size_changed.connect(_sl_viewport_size_changed)

func _sl_viewport_size_changed(save_: bool = true) -> void:
	var window_size: Vector2i = get_viewport().size
	words_container.size.x = window_size.x -30
	if save_:
		var arr: Array[Array] = [
			["window_size", "width", window_size.x],
			["window_size", "height", window_size.y],
		]
		SaveLoad.save(arr)

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		var pos: Vector2i = get_viewport().get_window().position
		var arr: Array[Array] = [
			["window_position", "x", pos.x],
			["window_position", "y", pos.y],
		]
		SaveLoad.save(arr, true)
