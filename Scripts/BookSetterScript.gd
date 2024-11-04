extends HBoxContainer

signal sl_book_changed(new_book_it: int)

@onready var _book_name_label: Label = $BookName

var _book_it: int
var _min_it: int

func _init() -> void:
	Global.book_setter = self

func _ready() -> void:
	SignalHandler.connect_signal(SignalHandler.Sl.DONE_LOADING, _sl_done_loading)
	Global.register_node_with_text($"Prev")
	Global.register_node_with_text($"Next")
	$"Prev".pressed.connect(_sl_prev_button_pressed)
	$"Next".pressed.connect(_sl_next_button_pressed)

func _sl_prev_button_pressed() -> void:
	_change_book(wrapi(_book_it - 1, 0, NewTestament.NUMBER_OF_BOOKS))

func _sl_next_button_pressed() -> void:
		_change_book(wrapi(_book_it + 1, 0, NewTestament.NUMBER_OF_BOOKS))

func _change_book(new_book_it: int) -> void:
	_book_it = new_book_it
	_book_name_label.text = NewTestament.get_book_name(_book_it)
	sl_book_changed.emit(new_book_it)

func _sl_done_loading() -> void:
	_change_book(0)
	_min_it = -1 if WordsList.is_loaded() else 0
