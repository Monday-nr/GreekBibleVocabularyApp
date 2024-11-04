extends HBoxContainer

@onready var batch_label: Label = $BatchLabel

signal sl_batch_changed

var _batch_start: int = 0
var _batch_end: int = 0
var _batch_it: int = 0

func _init() -> void:
	Global.batch_setter = self

func _ready() -> void:
	Global.register_node_with_text($"Prev")
	Global.register_node_with_text($"Next")
	SignalHandler.connect_signal(SignalHandler.Sl.WORD_LIMIT_CHANGED, _update_batch.unbind(1))
	SignalHandler.connect_signal(SignalHandler.Sl.WORDS_LIST_CHANGED, _reset.unbind(1))
	SignalHandler.connect_signal(SignalHandler.Sl.SORT_MODE_CHANGED, _sl_set_visibility.unbind(1))
	SignalHandler.connect_signal(SignalHandler.Sl.BOOK_CHANGED, _sl_set_visibility.unbind(1))
	$"Prev".pressed.connect(_sl_prev_button_pressed)
	$"Next".pressed.connect(_sl_next_button_pressed)

func _update_batch(new_it: int = _batch_it) -> void:
	var words_num: int = Global.get_current_list_length()
	var word_limit: int = Global.get_word_limit()
	@warning_ignore("integer_division")
	_batch_it = wrapi(new_it, 0, int((words_num - 1) / word_limit) + 1)
	_batch_start = word_limit * _batch_it
	_batch_end = _batch_start + word_limit
	if words_num <= _batch_end:
		_batch_end = words_num
	if _batch_end <= _batch_start:
		_batch_start = _batch_end - 1
	_update_label()


func _update_label() -> void:
	if Global.get_word_limit() == 1:
		batch_label.text = "Words %s-%s" % [1, Global.get_current_list_length()]
	else:
		batch_label.text = "Words: %s-%s of %s" % [_batch_start + 1, _batch_end, Global.get_current_list_length()]

func _reset() -> void:
	_update_batch(0)

func _sl_prev_button_pressed() -> void:
	_update_batch(_batch_it - 1)
	sl_batch_changed.emit()

func _sl_next_button_pressed() -> void:
	_update_batch(_batch_it + 1)
	sl_batch_changed.emit()

func _sl_set_visibility() -> void:
	set_visible(not Global.sort_mode_is(Global.SortMode.WORDS_BY_VERSES) or Global.is_using_word_list())
