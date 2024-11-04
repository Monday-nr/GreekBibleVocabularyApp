extends HBoxContainer

@onready var sort_label: Label = $SortLabel

signal sl_sort_mode_changed(_new_mode: Global.SortMode)

var _sort_mode: int = 0

func _init() -> void:
	Global.sort_mode_setter = self

func _ready() -> void:
	SignalHandler.connect_signal(SignalHandler.Sl.BOOK_CHANGED, _sl_book_changed)
	Global.register_node_with_text($"Prev")
	Global.register_node_with_text($"Next")
	$"Prev".pressed.connect(_sl_prev_button_pressed)
	$"Next".pressed.connect(_sl_next_button_pressed)

func _sl_prev_button_pressed() -> void:
	_change_sort_mode(-1)

func _sl_next_button_pressed() -> void:
	_change_sort_mode(1)

func _change_sort_mode(change: int) -> void:
	_sort_mode = wrapi(_sort_mode + change, 0, Global.SortMode.size())
	sort_label.text = Global.SortMode.keys()[_sort_mode].capitalize()
	sl_sort_mode_changed.emit(_sort_mode as Global.SortMode)

func _sl_book_changed(new_book_it: int) -> void:
	set_visible(new_book_it != WordsList.BOOK_IT)
