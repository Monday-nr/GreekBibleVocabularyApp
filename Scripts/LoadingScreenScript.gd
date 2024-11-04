extends ColorRect

const STARTUP_MESSAGE: String = "
	Press 'Enter', 'Space' or 'Left Mouse Button'
	to reveal the translation. Press again
	to show next word.

	Scroll up / down with the 'Mouse Wheel'
	or the 'Up/Down' arrow keys.

	Move the mouse to reveal the settings panel.
	"

signal sl_done_loading

@onready var words_container: VBoxContainer = $"../Words"
@onready var loading_screen_label: Label = $LoadingScreenLabel
@onready var progress_bar: ProgressBar = $ProgressBar

func _init() -> void:
	Global.loading_screen = self
	Global.register_alternate_background(self)

func _ready() -> void:
	display(true)
	call_deferred("_startup")

func _input(_event: InputEvent) -> void:
	get_viewport().set_input_as_handled()

func _gui_input(_event: InputEvent) -> void:
	get_viewport().set_input_as_handled()

func set_progress(amount: float) -> void:
	progress_bar.value = amount
	loading_screen_label.text = "Loading... %s%%" % int(amount)

func _startup() -> void:
	loading_screen_label.text = "Loading... 0%%"

	await Global.await_nodes(Global.get_all_child_nodes(get_tree().root))
	await Global.await_frames(2)

	await EnglishTranslation.load_version(SaveLoad.get_saved_english_translation_version())
	await ResourceHandler.load_new_testament()
	ResourceHandler._progress_amount = 100.0 / 27.0

	SignalHandler._connect_signals()
	SaveLoad._load_config()
	Global._update_words_list()
	sl_done_loading.emit()

	await Global.await_frames(2)

	display(false)
	Global.message.display(STARTUP_MESSAGE)


func display(display_: bool) -> void:
	if display_:
		set_process_input(true)
		Controls.enable(false)
		set_visible(true)
		z_index = 1000
		focus_mode = FOCUS_ALL
		mouse_filter = MOUSE_FILTER_STOP
	else:
		set_process_input(false)
		Controls.enable(true)
		set_visible(false)
		z_index = -1000
		focus_mode = FOCUS_NONE
		mouse_filter = MOUSE_FILTER_IGNORE
