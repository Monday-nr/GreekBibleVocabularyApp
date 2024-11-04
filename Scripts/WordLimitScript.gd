extends HBoxContainer

@onready var word_limit_label: Label = $WordLimitLabel

signal sl_word_limit_changed(new_limit: int)

var _word_limit: int = 10

func _init() -> void:
	Global.word_limit_setter = self

func _ready() -> void:
	Global.register_node_with_text($"Prev")
	Global.register_node_with_text($"Next")
	$"Prev".pressed.connect(_sl_prev_button_pressed)
	$"Next".pressed.connect(_sl_next_button_pressed)
	SignalHandler.connect_signal(SignalHandler.Sl.DONE_LOADING, _sl_done_loading)
	SignalHandler.connect_signal(SignalHandler.Sl.SORT_MODE_CHANGED, _sl_set_visibility.unbind(1))
	SignalHandler.connect_signal(SignalHandler.Sl.BOOK_CHANGED, _sl_set_visibility.unbind(1))

func _sl_prev_button_pressed() -> void:
	_change_word_limit(-1)

func _sl_next_button_pressed() -> void:
		_change_word_limit(1)

func _change_word_limit(change: int) -> void:
	_word_limit = clampi(_word_limit + change, 1, 999999)
	if _word_limit == 1:
		word_limit_label.text = "No Word Limit"
	else:
		word_limit_label.text = "Word Limit: %s" % _word_limit
	sl_word_limit_changed.emit(_word_limit)

func _sl_done_loading() -> void:
	_change_word_limit(0)

func _sl_set_visibility() -> void:
	set_visible(not Global.sort_mode_is(Global.SortMode.WORDS_BY_VERSES) or Global.is_using_word_list())
